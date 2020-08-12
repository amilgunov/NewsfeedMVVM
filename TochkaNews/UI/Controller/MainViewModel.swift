//
//  MainViewModel.swift
//  TochkaNews
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

protocol MainViewModelType {
    
    var results: PublishSubject<[CellViewModel]> { get }
    var state: CurrentState { get set }
    var title: Observable<String> { get }
    
    func initialFetchData()
    func updateData(for page: PageType)
    func cellViewModel(for indexPath: IndexPath) -> CellViewModel
}

final class MainViewModel: MainViewModelType {
    
    private var dataManager: DataManagerType
    private var currentPage: Int
    private let mockRequest = "apple"
    private let disposeBag = DisposeBag()

    public let results = PublishSubject<[CellViewModel]>()
    public var state: CurrentState = .completed
    public var title: Observable<String>
    
    lazy var fetchedResultsController: NSFetchedResultsController<NewsEntity> = {
        
        let fetchRequest = NSFetchRequest<NewsEntity>(entityName: NewsEntity.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataManager.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        
        return controller
    }()
    
    public func initialFetchData() {
        fetchFromCoreData()
        updateData(for: .firstPage)
    }
    
    private func fetchFromCoreData() {
        
        do {
            try fetchedResultsController.performFetch()
            let cellViewModels = (fetchedResultsController.fetchedObjects ?? [NewsEntity]()).map { CellViewModel(for: $0) }
            results.onNext(cellViewModels)
            state = .completed
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    public func updateData(for page: PageType) {
        
        state = .loading
        
        switch page {
        case .firstPage:
            currentPage = 1
        case .nextPage:
            currentPage += 1
        }
        
        dataManager.fetchData(request: mockRequest, page: currentPage)
    }

    public func cellViewModel(for indexPath: IndexPath) -> CellViewModel {
        
        let object = fetchedResultsController.object(at: indexPath)
        let cellViewModel = CellViewModel(for: object)
        
        return cellViewModel
    }
    
    func bindToManagerTrigger() {
        
        dataManager.trigger
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .failure(let error):
                    self.currentPage -= 1
                    self.state = .completed
                    print(error.localizedDescription)
                case .success:
                    self.fetchFromCoreData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    init(with manager: DataManagerType) {
        
        currentPage = 0
        dataManager = manager
        
        title = Observable.of("Tochka news")
        bindToManagerTrigger()
    }
}

enum PageType {
    case firstPage, nextPage
}

enum CurrentState {
    case completed, loading
}
