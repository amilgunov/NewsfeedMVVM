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
}

class DataManager: DataManagerType {
    
    private let networkManager: NetworkManagerType
    private let coreDataManager: CoreDataManager
    
    private(set) var fetchNewDataTrigger = PublishSubject<Int>()
    private(set) var observableData = PublishSubject<[NewsEntity]>()
    
    private let disposeBag = DisposeBag()
    
    private func bindTrigger() {
        
        fetchNewDataTrigger
            .subscribe(onNext: {
                self.fetchNewData(page: $0)
            })
            .disposed(by: disposeBag)
        
        coreDataManager.observableData
            .bind(to: observableData)
            .disposed(by: disposeBag)
    }

    public func fetchNewData(page: Int) {
        
        networkManager.getData(page: page) { [weak self] result in
            
            switch result {
            case .failure(let error):
                //self?.trigger.onNext(.failure(error))
            fatalError()
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
