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
//
//let imageCache = NSCache<NSString, UIImage>()

//extension UIImageView {
//    
//    func loadImage(from URLString: String, defaultImage: UIImage?) -> Observable<UIImage> {
//        
//        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
//            return Observable<UIImage>.just(cachedImage)
//        }
//        
//        return NetworkManager().getNewsImage(from: URLString)
//            .delay(.seconds(1), scheduler: MainScheduler.instance)
//            .map { imageData in
//                if let downloadedImage = UIImage(data: imageData) {
//                    imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
//                    return downloadedImage
//                } else {
//                    return defaultImage!
//                }
//            }
//
//    }
//}
