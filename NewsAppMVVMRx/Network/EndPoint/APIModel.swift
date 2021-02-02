//
//  JSONModel.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 13.08.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation

struct NewsFeed: Codable {
    let status: String
    let totalResults: Int
    let articles: [News]
}

struct News: Codable {
    let source: Source?
    let author: String?
    let title, newsDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case newsDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

struct Source: Codable {
    let id: String?
    let name: String
}
