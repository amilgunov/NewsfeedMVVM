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
    var dataObservable: PublishSubject<[NewsEntity]> { get }
    var errorsObservable: PublishSubject<Error> { get }
}

class DataManager: DataManagerType {
    
    private let networkManager: NetworkManagerType
    private let coreDataManager: CoreDataManager
    
    private(set) var fetchNewDataTrigger = PublishSubject<Int>()
    private(set) var dataObservable = PublishSubject<[NewsEntity]>()
    private(set) var errorsObservable = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    
    private func bindTrigger() {
        
        fetchNewDataTrigger
            .subscribe(onNext: {
                self.fetchNewData(page: $0)
            })
            .disposed(by: disposeBag)
        
        coreDataManager.coreDataObservable
            .bind(to: dataObservable)
            .disposed(by: disposeBag)
        
        coreDataManager.errorsObservable
            .bind(to: errorsObservable)
            .disposed(by: disposeBag)
    }

    public func fetchNewData(page: Int) {
        
        networkManager.getData(page: page) { [weak self] result in
            
            switch result {
            case .failure(let error):
                self?.errorsObservable.onNext(error)
                self?.coreDataManager.syncData(dataNews: [News](), isTopPage: page == 1)
            case .success(let data):
                self?.coreDataManager.syncData(dataNews: data as! [News], isTopPage: page == 1)
            }
        }
    }
    
     init(coreDataManager: CoreDataManager, networkManager: NetworkManagerType) {

        self.coreDataManager = coreDataManager
        self.networkManager = networkManager

        bindTrigger()
    }
}
