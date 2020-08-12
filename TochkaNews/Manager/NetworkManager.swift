//
//  NetworkManager.swift
//  TochkaNews
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkManagerType: class {
    
    static var shared: NetworkManagerType { get }
    func getData(request: String, page: Int, _ completion: @escaping FetchCompletion)
    func getImageData(from: String, _ completion: @escaping FetchCompletion)
}

class NetworkManager: NetworkManagerType {
    
    private let apiSettings = APISettings()
    
    static let shared: NetworkManagerType = NetworkManager()
    
    func getData(request: String, page: Int, _ completion: @escaping FetchCompletion) {
        
        let parameters: Parameters = ["q": request, "apiKey": apiSettings.apiKey, "page": page]
        
        AF.request(apiSettings.url, method: .get, parameters: parameters).validate().responseDecodable(of: NewsFeed.self, decoder: JSONDecoder()) { newsResponse in
            
            switch newsResponse.result {
            case .success(let newsResponse):
                completion(.success(newsResponse.articles))
            case .failure(let error):
                completion(.failure(NSError(domain: "", code: error.responseCode ?? 0, userInfo: ["Error": error.errorDescription ?? ""])))
            }
        }
    }
    
    func getImageData(from: String, _ completion: @escaping FetchCompletion) {
        
        AF.request(from, method: .get).validate().responseData { response in
            
            switch response.result {
            case .success(let imageData):
                completion(.success(imageData))
            case .failure(let error):
                completion(.failure(NSError(domain: "", code: error.responseCode ?? 0, userInfo: ["Error": error.errorDescription ?? ""])))
            }
        }
    }
}
