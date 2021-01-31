//
//  Extension.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImage(from URLString: String, defaultImage: UIImage?) -> Observable<UIImage> {
        
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            return Observable<UIImage>.just(cachedImage)
        }
        
        return NetworkManager().getImageData(from: URLString)
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .catchError({ error -> Observable<Data> in
                throw RxCocoaURLError.deserializationError(error: error)
            })
            .map { imageData in
                if let downloadedImage = UIImage(data: imageData) {
                    imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                    return downloadedImage
                } else {
                    return defaultImage!
                }
            }

    }
}
