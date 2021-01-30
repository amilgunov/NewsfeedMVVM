//
//  NetworkManager.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire


typealias FetchCompletion = (Result<Any, Error>) -> Void

protocol NetworkManagerType: class {
    func load(page: Int) -> Observable<[News]>
    func getImageData(from: String, _ completion: @escaping FetchCompletion)
}

final class NetworkManager: NetworkManagerType {

    private(set) var newsDataObservable = PublishSubject<[News]>()
    private let apiSettings = APIConstants()
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    
    func load(page: Int) -> Observable<[News]> {
        
        guard let url = apiSettings.url(with: page) else { return Observable.empty() }
        
        return RxAlamofire.requestData(.get, url)
            .observeOn(scheduler)
            .map { response, data -> [News] in
                if 200..<300 ~= response.statusCode {
                    do {
                        let json = try JSONDecoder().decode(NewsFeed.self, from: data)
                        return json.articles
                    } catch {
                        throw RxCocoaURLError.deserializationError(error: error)
                    }
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
  
    let queue = DispatchQueue(label: "networkQueue", qos: .utility, attributes: .concurrent)
    func getImageData(from: String, _ completion: @escaping FetchCompletion) {
    
            AF.request(from, method: .get).validate().responseData(queue: queue) { response in
    
                switch response.result {
                case .success(let imageData):
                    completion(.success(imageData))
                case .failure(let error):
                    completion(.failure(NSError(domain: "", code: error.responseCode ?? 0, userInfo: ["Error": error.errorDescription ?? ""])))
                }
            }
        }
}
