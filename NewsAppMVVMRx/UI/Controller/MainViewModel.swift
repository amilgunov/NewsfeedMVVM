//
//  MainViewModel.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

protocol MainViewModelType {
    
    var fetchTrigger: PublishSubject<FetchType> { get }
    var cells: PublishSubject<[CellViewModel]> { get }
    var title: Observable<String> { get }
    var state: CurrentState { get set }
}

final class MainViewModel: MainViewModelType {
    
    private var dataManager: DataManagerType
    private var currentPage: Int
    private let mockRequest = "apple"
    private let disposeBag = DisposeBag()
    
    //MARK: - Input
    public let fetchTrigger = PublishSubject<FetchType>()

    //MARK: - Output
    public let cells = PublishSubject<[CellViewModel]>()
    public let title: Observable<String>
    
    public var state: CurrentState = .completed
    
    private func updateData(for pageType: PageType) {
        
        state = .loading
        
        switch pageType {
        case .firstPage:
            currentPage = 1
        case .nextPage:
            currentPage += 1
        }
        
        DispatchQueue.global().async {
            self.dataManager.fetchNewData(request: self.mockRequest, page: self.currentPage)
        }
    }
    
    func bindToDataManager() {
        
        fetchTrigger
            .subscribe(onNext: { [unowned self] fetchType in
                switch fetchType {
                case .initial:
                    self.dataManager.fetchSavedData()
                    self.updateData(for: .firstPage)
                case .update(let pageType):
                    self.updateData(for: pageType)
                }
            })
            .disposed(by: disposeBag)
        
        dataManager.findings
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .failure:
                    self.currentPage -= 1
                case .success(let cellViewModels):
                    self.cells.onNext(cellViewModels)
                }
                self.state = .completed
            })
            .disposed(by: disposeBag)
    }
    
    init(with manager: DataManagerType) {
        
        currentPage = 0
        dataManager = manager
        
        title = Observable.of("News App MVVM+Rx")
        bindToDataManager()
    }
}

enum PageType {
    case firstPage, nextPage
}

enum CurrentState {
    case completed, loading
}

enum FetchType {
    case initial
    case update(PageType)
}
