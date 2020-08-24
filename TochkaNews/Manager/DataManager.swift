//
//  DataManager.swift
//  TochkaNews
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol DataManagerType {
    
    var findings: PublishSubject<Result<[CellViewModel], Error>> { get }
    
    func fetchSavedData()
    func fetchNewData(request: String, page: Int)
}

class DataManager: DataManagerType {
    
    private var persistentContainer: NSPersistentContainer
    private let networkManager: NetworkManagerType
        
    private(set) var findings = PublishSubject<Result<[CellViewModel], Error>>()
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
        
        trigger
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    self.fetchSavedData()
                }
            })
            .disposed(by: disposeBag)
    }

    public func fetchSavedData() {
        
        do {
            try fetchedResultsController.performFetch()
            let cellViewModels = (fetchedResultsController.fetchedObjects ?? [NewsEntity]()).map { CellViewModel(for: $0) }
            findings.onNext(.success(cellViewModels))
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    public func fetchNewData(request: String, page: Int) {
        
        networkManager.getData(request: request, page: page) { [weak self] result in
            
            switch result {
            case .failure(let error):
                self?.trigger.onNext(.failure(error))
            case .success(let data):
                let taskContext = self?.persistentContainer.newBackgroundContext()
                taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext?.undoManager = nil
                
                if let data = data as? [News] {
                    self?.syncData(dataNews: data, taskContext: taskContext)
                }
            }
        }
    }
    
    private func syncData(dataNews: [News], taskContext: NSManagedObjectContext?) {
        
        guard let taskContext = taskContext else {
            trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": ""])))
            return
        }
        
        taskContext.performAndWait {
            
            let matchingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NewsEntity.entityName)
            let newsIds = dataNews.map { $0.title }.compactMap { $0 }
            matchingRequest.predicate = NSPredicate(format: "title in %@", argumentArray: [newsIds])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                trigger.onNext(.failure(NSError(domain: "", code: 0, userInfo: ["Error": error])))
                return
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
            }
        }
    }

     init(persistentContainer: NSPersistentContainer, networkManager: NetworkManagerType) {
        
        self.persistentContainer = persistentContainer
        self.networkManager = networkManager

        bindTrigger()
    }
}
