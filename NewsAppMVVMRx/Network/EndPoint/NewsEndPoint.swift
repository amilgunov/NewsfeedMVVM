//
//  NewsEndPoint.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 01.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Foundation
import Alamofire

public enum NewsEndPoint {
    case news(page: Int)
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
        return "/v2/top-headlines"
    }
    
    private var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: "business"),
            URLQueryItem(name: "apiKey", value: "27951c65db6a4dd0bb7d3d7e7f1c1fdd")
        ]
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var url: URL? {
        switch self {
        case .news(let page):
            return configureURL(with: page)
        case .photo(let imageUrl):
            return URL(string: imageUrl)
        }
    }
    
    private func configureURL(with page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path
        components.queryItems = queryItems
        components.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        return components.url
    }
}
