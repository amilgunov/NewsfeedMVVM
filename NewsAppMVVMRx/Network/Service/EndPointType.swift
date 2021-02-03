//
//  EndPointType.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 01.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Alamofire

protocol EndPointType {
    var url: URL? { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}
