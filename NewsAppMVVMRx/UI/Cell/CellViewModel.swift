//
//  CellViewModel.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol CellViewModelType {
    
    var identitySubject: String { get }
    var title:      Driver<String> { get }
    var author:     Driver<String> { get }
    var urlToImage: Observable<String> { get }
}

final class CellViewModel: CellViewModelType, IdentifiableType, Equatable {
    
    let identitySubject: String
    let title:      Driver<String>
    let author:     Driver<String>
    let urlToImage: Observable<String>
    
    init(for news: NewsEntity) {
        
        let date = NewsEntity.dateFormatter.string(from: news.publishedAt ?? Date())
        
        identitySubject = (news.title ?? "") + date
        title = Observable.of(news.title ?? "").asDriver(onErrorJustReturn: "")
        author = Observable.of((news.author ?? "") + " at " + date).asDriver(onErrorJustReturn: "")
        urlToImage = Observable.of(news.urlToImage ?? "")
    }
}

extension CellViewModel {
    
    public var identity: String {
      return identitySubject
    }
    
    static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}
