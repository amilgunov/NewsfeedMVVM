//
//  Router.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 01.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import RxSwift
import RxAlamofire

protocol NetworkRouter: class {
    
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint) -> Observable<Data>
}

class Router<EndPoint: EndPointType>: NetworkRouter {
 
    func request(_ route: EndPoint) -> Observable<Data> {
        guard let url = route.url else { return Observable.error(ApiError.urlConfigurationError) }
        return RxAlamofire.request(route.httpMethod, url, headers: route.headers)
            .validate(statusCode: 200 ..< 300)
            .data()
    }
}

enum ApiError: Error {
    
    case urlConfigurationError
    case httpRequestFailed
    case deserializationError
}
