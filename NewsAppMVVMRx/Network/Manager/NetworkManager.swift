//
//  ApiClient.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.01.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//
import Foundation
import RxSwift
import RxAlamofire
import Alamofire

protocol NetworkManagerType: class {
    func getNews(page: Int) -> Observable<[News]>
    func getNewsImage(from: String) -> Observable<Data>
}

class NetworkManager: NetworkManagerType {
    
    static let environment : NetworkEnvironment = .production
    private let newsRouter = Router<NewsEndPoint>()
    
    func getNews(page: Int) -> Observable<[News]> {
        newsRouter.request(.news(page: page))
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

enum ApiError: Error {
    case urlConfigurationError
    case deserializationError
    case forbidden              //Status code 403
    case notFound               //Status code 404
    case conflict               //Status code 409
    case internalServerError    //Status code 500
}
