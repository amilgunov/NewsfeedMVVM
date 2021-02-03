//
//  ApiClient.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 30.01.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import RxSwift
import RxAlamofire

protocol NetworkManagerType: class {
    func getHeadlines(page: Int) -> Observable<[News]>
    func getNewsImage(from: String) -> Observable<Data>
}

class NetworkManager: NetworkManagerType {
    
    private let newsRouter = Router<NewsEndPoint>()
    
    func getHeadlines(page: Int) -> Observable<[News]> {
        newsRouter.request(.headlines(page: page))
            .map { data -> [News] in
                do {
                    let json = try JSONDecoder().decode(NewsFeed.self, from: data)
                    return json.articles
                } catch {
                    throw ApiError.deserializationError
                }
            }
    }
    
    func getNewsImage(from url: String) -> Observable<Data> {
        return newsRouter.request(.photo(imageUrl: url))
    }
}
