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

protocol NetworkManagerType: class {
    func load(page: Int) -> Observable<[News]>
    func getImageData(from: String) -> Observable<Data>
}

class NetworkManager: NetworkManagerType {

    func load(page: Int) -> Observable<[News]> {
        return RxAlamofire.request(.get, APIConstants().url(with: page)!)
            .validate(statusCode: 200 ..< 300)
            .data()
            .map { data -> [News] in
                do {
                    let json = try JSONDecoder().decode(NewsFeed.self, from: data)
                    return json.articles
                } catch {
                    throw ApiError.deserializationError
                }
            }
    }
    
    func getImageData(from url: String) -> Observable<Data> {
        return RxAlamofire.request(.get, url)
            .validate(statusCode: 200 ..< 300)
            .data()
    }

}

enum ApiError: Error {
    case deserializationError
    case forbidden              //Status code 403
    case notFound               //Status code 404
    case conflict               //Status code 409
    case internalServerError    //Status code 500
}
