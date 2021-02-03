//
//  NewsEndPoint.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 01.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Alamofire

public enum NewsEndPoint {
    case headlines(page: Int)
    case photo(imageUrl: String)
}

extension NewsEndPoint: EndPointType {
    
    private var scheme: String {
        return "https"
    }
    
    private var host: String {
        return "newsapi.org"
    }
    
    private var path: String {
        switch self {
        case .headlines:
            return "/v2/top-headlines"
        default:
            return ""
        }
    }
    
    private var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: "business")
        ]
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return [HTTPHeader(name: "X-Api-Key", value: "27951c65db6a4dd0bb7d3d7e7f1c1fdd")]
    }
    
    var url: URL? {
        switch self {
        case .headlines(let page):
            return configureURL(with: page)
        case .photo(let imageUrl):
            return URL(string: imageUrl)
        }
    }
    
    private func configureURL(with page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        components.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        return components.url
    }
}
