//
//  ProfilePictureApi.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/9/24.
//

import UIKit
import SVGKit

func generateRandomString(length: Int = 5) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).compactMap { _ in letters.randomElement() })
}

func fetchSVGImage(from urlString: String = "https://api.dicebear.com/9.x/lorelei/svg?seed=\(generateRandomString())", completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        // Convert SVG data to UIImage
        if let svgImage = SVGKImage(data: data) {
            let uiImage = svgImage.uiImage
            completion(uiImage)
        } else {
            completion(nil)
        }
    }
    
    task.resume()
}

// Usage
//let svgURL = "https://api.dicebear.com/9.x/lorelei/svg?seed=john"
//fetchSVGImage(from: svgURL) { image in
//    DispatchQueue.main.async {
//        if let image = image {
//            // Use the UIImage (e.g., assign it to an UIImageView)
//            imageView.image = image
//        } else {
//            print("Failed to load SVG image")
//        }
//    }
//}
