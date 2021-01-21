//
//  DataManager.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol DataManagerType {
    
    var fetchNewDataTrigger: PublishSubject<Int> { get }
    var observableData: PublishSubject<[NewsEntity]> { get }
    
    func fetchSavedData()
    func fetchNewData(page: Int)
}

class DataManager: DataManagerType {
    
    public let fetchNewDataTrigger = PublishSubject<Int>()
    
    private var persistentContainer: NSPersistentContainer
    private let networkManager: NetworkManagerType
        
    private(set) var observableData = PublishSubject<[NewsEntity]>()
    private var trigger = PublishSubject<Result<Any, Error>>()
    private let disposeBag = DisposeBag()

    lazy var fetchedResultsController: NSFetchedResultsController<NewsEntity> = {
        
        let fetchRequest = NSFetchRequest<NewsEntity>(entityName: NewsEntity.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    
    private func bindTrigger() {
        
        fetchNewDataTrigger
            .subscribe(onNext: {
                self.fetchNewData(page: $0)
            })
            .disposed(by: disposeBag)
        
        trigger
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .failure(let error):
                    print(error)
                    self.fetchSavedData()
                case .success:
                    self.fetchSavedData()
                }
            })
            .disposed(by: disposeBag)
    }

    public func fetchSavedData() {
        
        do {
            try fetchedResultsController.performFetch()
            let newsEntities = (fetchedResultsController.fetchedObjects ?? [NewsEntity]())
            observableData.onNext(newsEntities)
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    public func fetchNewData(page: Int) {
        
        networkManager.getData(page: page) { [weak self] result in
            
            switch result {
            case .failure(let error):
                self?.trigger.onNext(.failure(error))
            case .success(let data):
                let taskContext = self?.persistentContainer.newBackgroundContext()
                taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext?.undoManager = nil
                
                if let data = data as? [News] {
                    self?.syncData(dataNews: data, taskContext: taskContext, isTopPage: page == 1)
                }
            }
        }
    }
    
    private func syncData(dataNews: [News], taskContext: NSManagedObjectContext?, isTopPage: Bool) {
        
        guard let taskContext = taskContext else {
            trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": ""])))
            return
        }
        
        taskContext.performAndWait {
            
            if isTopPage && dataNews.count > 0 {
                let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NewsEntity.entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)

                do {
                    try taskContext.execute(deleteRequest)
                } catch let error as NSError {
                    //trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": error])))
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
                    trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": error])))
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
                    trigger.onNext(.success(true))
                } catch {
                    trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": error])))
                }
                taskContext.reset()
            } else {
                trigger.onNext(.success(true))
            }
        }
    }

     init(persistentContainer: NSPersistentContainer, networkManager: NetworkManagerType) {
        
        self.persistentContainer = persistentContainer
        self.networkManager = networkManager

        bindTrigger()
    }
}
