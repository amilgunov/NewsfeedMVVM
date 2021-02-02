//
//  MainViewModel.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import RxSwift
import RxCocoa

protocol MainViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

final class MainViewModel: MainViewModelType {
    
    private var dataManager: DataManagerType
    private let isLoading = PublishSubject<Bool>()
    private let pageTrigger = BehaviorRelay<Int>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    struct Input {
        let fetchTopTrigger: Driver<Void>
        let reachedBottomTrigger: Driver<Void>
    }
    
    //MARK: - Outputs
    struct Output {
        let isLoading: Driver<Bool>
        let title: Driver<String>
        let cells: Driver<[CellViewModel]>
        let alert: Driver<String>
    }
    
    func startUp() {
        dataManager.fetchNewDataTrigger.onNext(0)
    }
    
    func transform(input: Input) -> Output {
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        // MARK: - Request to data manager
        
        /// pageTrigger -> page #1 when triggered TOP
        input.fetchTopTrigger.asObservable()
            .observeOn(scheduler)
            .withLatestFrom(isLoading)
            .filter { !$0 }
            .map { _ in 1 }
            .bind(to: pageTrigger)
            .disposed(by: disposeBag)

        /// pageTrigger -> page #+1 when triggered BOTTOM
        input.reachedBottomTrigger.asObservable()
            .observeOn(scheduler)
            .withLatestFrom(isLoading)
            .filter { !$0 }
            .withLatestFrom(pageTrigger)
            .map { $0 + 1 }
            .bind(to: pageTrigger)
            .disposed(by: disposeBag)
        
        /// Start isLoading
        pageTrigger
            .map { _ in true }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        /// Request to data manager
        pageTrigger
            .bind(to: dataManager.fetchNewDataTrigger)
            .disposed(by: disposeBag)
        
        // MARK: - Receive data from data manager
        
        let dataObservable = dataManager.dataObservable
            .share()
        
        let titleDriver = isLoading
            .map { $0 ? "Updating..." : "Newsfeed" }
            .asDriver(onErrorJustReturn: "Something goes wrong...")
        
        let cellsDriver = dataObservable
            .map { $0.map { CellViewModel(for: $0) }.unique() }
            .map { $0.sorted { $0.publishedAt > $1.publishedAt } }
            .asDriver(onErrorJustReturn: [])
        
        dataObservable
            .catchErrorJustReturn([])
            .map { _ in false }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        let errors = dataManager.errorsObservable
            .map { $0.localizedDescription }
            .asDriver(onErrorJustReturn: "")
        
        return Output(isLoading: isLoading.asDriver(onErrorJustReturn: false), title: titleDriver, cells: cellsDriver, alert: errors)
    }
    
    init(with manager: DataManagerType) {
        dataManager = manager
    }
}



