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
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

final class MainViewModel: MainViewModelType {
    
    
    private var dataManager: DataManagerType
    private let page = BehaviorRelay<Int>(value: 1)
    
    private var currentPage: Int
    private let mockRequest = "apple"
    private let disposeBag = DisposeBag()
    
    private let fetchTrigger = PublishSubject<FetchType>()
    private let reachedBottomTrigger = PublishSubject<Void>()
    
    let isLoading = PublishSubject<Bool>()

    
    //MARK: - Inputs
    struct Input {
        let fetchTrigger: Driver<Void>
        let reachedBottomTrigger: Observable<Void>
    }
    
    //MARK: - Outputs
    struct Output {
        let cells: PublishSubject<[CellViewModel]>
        let title: Driver<String>
        let isLoading: Driver<Bool>
    }
    public let cells = PublishSubject<[CellViewModel]>()
    public let title: Observable<String>
    
    public var state: CurrentState = .completed
    
    func transform(input: Input) -> Output {
        
        isLoading.subscribe(onNext: {
            print("IS LOADING NOW IS \($0)")
        }).disposed(by: disposeBag)
        
        input.fetchTrigger.asObservable()
            .flatMap { Observable<Bool>.just(true) }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
            
        
        input.fetchTrigger.asObservable()
            .subscribe(onNext: { [unowned self] in
                
                self.dataManager.fetchSavedData()
            })
            .disposed(by: disposeBag)
        
        input.reachedBottomTrigger
//            .withLatestFrom(isLoading)
//            .filter { !$0 }
            .subscribe(onNext: { [weak self] in
                var page = (self?.page.value ?? 1) + 1
                self?.page.accept(page)
                print(page)
            })
            .disposed(by: disposeBag)
        
        dataManager.observableData.share()
            .flatMap { _ in Observable<Bool>.just(false) }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        dataManager.observableData
            .map { $0.map { CellViewModel(for: $0) }
            }
            .subscribe(onNext: { [unowned self] cellViewModels in
                self.cells.onNext(cellViewModels)
                self.state = .completed
                self.isLoading.onNext(false)
            })
            .disposed(by: disposeBag)
        
        return Output(cells: self.cells,
                      title: Observable.just("News App").asDriver(onErrorJustReturn: ""),
                      isLoading: isLoading.asDriver(onErrorJustReturn: false))
    }
    
    private func updateData(for pageType: PageType) {
        
        state = .loading
        
        switch pageType {
        case .firstPage:
            currentPage = 1
        case .nextPage:
            currentPage += 1
        }
        
//        DispatchQueue.global().async {
//            self.dataManager.fetchNewData(request: self.mockRequest, page: self.currentPage)
//        }
    }
    
    init(with manager: DataManagerType) {
        
        currentPage = 0
        dataManager = manager
        
        title = Observable.of("News App MVVM+Rx")
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
