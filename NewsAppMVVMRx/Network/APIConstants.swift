//
//  APISettings.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 12.08.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation

struct APIConstants {
    
    var scheme = "https"
    var host = "newsapi.org"
    var path = "/v2/top-headlines"
    var country = "us"
    var category = "business"
    var apiKey = "27951c65db6a4dd0bb7d3d7e7f1c1fdd"
    //let apiKey = "5884d47a778f44519650a599f2d3839d"
    
    func url(with page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path
        components.queryItems = [
            URLQueryItem(name: "country", value:  self.country),
            URLQueryItem(name: "category", value: self.category),
            URLQueryItem(name: "apiKey", value: self.apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        return components.url
    }
}
