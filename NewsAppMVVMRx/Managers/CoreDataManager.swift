//
//  CoreDataManager.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 23.01.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

final class CoreDataManager {
    
    private(set) var coreDataObservable = PublishSubject<[NewsEntity]>()
    private(set) var errorsObservable = PublishSubject<Error>()
    private var persistentContainer: NSPersistentContainer
    
    lazy var fetchedResultsController: NSFetchedResultsController<NewsEntity> = {
        
        let fetchRequest = NSFetchRequest<NewsEntity>(entityName: NewsEntity.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    
    public func fetchSavedData() {
        do {
            try fetchedResultsController.performFetch()
            let newsEntities = (fetchedResultsController.fetchedObjects ?? [NewsEntity]())
            coreDataObservable.onNext(newsEntities)
        } catch {
            let error = error
            errorsObservable.onNext(error)
            coreDataObservable.onNext([NewsEntity]())
        }
    }
    
    func syncData(dataNews: [News], erase: Bool) {
        
        let taskContext = self.persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        
        taskContext.performAndWait {
            if dataNews.count > 0 && erase {
                let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NewsEntity.entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
                
                do {
                    try taskContext.execute(deleteRequest)
                } catch let error as NSError {
                    errorsObservable.onNext(error)
                    fetchSavedData()
                }
            } else {
                let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NewsEntity.entityName)
                let newsIds = dataNews.map { $0.title }.compactMap { $0 }
                matchingRequest.predicate = NSPredicate(format: "title in %@", argumentArray: [newsIds])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                
                do {
                    let deleteRequest = try taskContext.execute(deleteRequest) as? NSBatchDeleteResult
                    
                    if let deletedObjectIDs = deleteRequest?.result as? [NSManagedObjectID] {
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                            into: [self.persistentContainer.viewContext])
                    }
                } catch {
                    errorsObservable.onNext(error)
                    fetchSavedData()
                    return
                }
            }
            
            for item in dataNews {
                guard let news = NSEntityDescription.insertNewObject(forEntityName: NewsEntity.entityName, into: taskContext) as? NewsEntity else {
                    return
                }
                
                do {
                    try news.update(with: item)
                } catch {
                    taskContext.delete(news)
                }
            }
            
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    errorsObservable.onNext(error)
                }
                taskContext.reset()
            }
            fetchSavedData()
        }
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}
