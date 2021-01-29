//
//  Extension.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImage(from URLString: String, defaultImage: UIImage?) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        NetworkManager().getImageData(from: URLString) { [weak self] result in
            
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self?.image = defaultImage
                }
                return
            case .success(let imageData):
                if let imageData = imageData as? Data, let downloadedImage = UIImage(data: imageData) {
                    imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                    DispatchQueue.main.async {
                        self?.image = downloadedImage
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.image = defaultImage
                    }
                }
            }
        }
    }
}
