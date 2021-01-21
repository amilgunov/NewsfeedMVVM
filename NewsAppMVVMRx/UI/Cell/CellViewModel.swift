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
    
    var identity: String { get }
    var publishedAt: Date { get }
    var title:      Driver<String> { get }
    var author:     Driver<String> { get }
    var urlToImage: Observable<String> { get }
}

final class CellViewModel: CellViewModelType, IdentifiableType {
    
    let identity: String
    let publishedAt: Date
    let title:      Driver<String>
    let author:     Driver<String>
    let urlToImage: Observable<String>
    
    init(for news: NewsEntity) {
        
        let date = NewsEntity.dateFormatter.string(from: news.publishedAt ?? Date())
        
        identity = (news.title ?? "") + news.description.prefix(10) + date
        publishedAt = news.publishedAt ?? Date()
        title = Observable.of(news.title ?? "").asDriver(onErrorJustReturn: "")
        author = Observable.of((news.author ?? "") + " at " + date).asDriver(onErrorJustReturn: "")
        urlToImage = Observable.of(news.urlToImage ?? "")
    }
}

extension CellViewModel: Equatable {
    static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension CellViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
