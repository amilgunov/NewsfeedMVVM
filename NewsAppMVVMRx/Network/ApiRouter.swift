//
//  ApiRouter.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.01.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Foundation
import Alamofire

enum ApiRouter: URLRequestConvertible {
    
    case getNews(page: Int)
    
    func asURLRequest() throws -> URLRequest {
        
        guard let url = url else { fatalError() }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
//        urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.acceptType.rawValue)
//        urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.contentType.rawValue)
        

        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: nil)
    }
    
    private var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
        }
    }
    
    private var path: String {
        switch self {
        case .getNews:
            return "posts"
        }
    }
    
    private var url: URL? {
        switch self {
        case .getNews(let page):
            return APIConstants().url(with: page)
        }
    }
}

enum ApiError: Error {
    case forbidden              //Status code 403
    case notFound               //Status code 404
    case conflict               //Status code 409
    case internalServerError    //Status code 500
}
