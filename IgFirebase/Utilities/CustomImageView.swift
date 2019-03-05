//
//  CustomImageView.swift
//  IgFirebase
//
//  Created by Derek on 2019/2/28.
//  Copyright © 2019 Derek. All rights reserved.
//

import UIKit

var imageCache = [String:UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage:String?
    
    func loadImage(urlString:String) {
       
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch post image:", error)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                print("Url.absoluteString: \(url.absoluteString) \n lastURLUsedToLoadImage: \(self.lastURLUsedToLoadImage)")
                return
            }
            
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
            }.resume()
        
    }
}
