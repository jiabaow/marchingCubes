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

func fetchSVGBase64(from urlString: String = "https://api.dicebear.com/9.x/lorelei/svg?seed=\(generateRandomString())", completion: @escaping (String?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        // Convert SVG data to Base64-encoded string
        let base64String = data.base64EncodedString()
        let svgBase64String = "data:image/svg+xml;base64,\(base64String)"
        
        completion(svgBase64String)
    }
    
    task.resume()
}

func fetchSVGBase64Async(from urlString: String = "https://api.dicebear.com/9.x/lorelei/svg?seed=\(generateRandomString())&size=120") async -> String? {
    guard let url = URL(string: urlString) else {
        return nil
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        // Convert SVG data to Base64-encoded string
        let base64String = data.base64EncodedString()
        let svgBase64String = "data:image/svg+xml;base64,\(base64String)"
        return svgBase64String
    } catch {
        print("Error fetching SVG: \(error)")
        return nil
    }
}

func loadSVGImage(from base64String: String) -> UIImage? {
    // Remove the "data:image/svg+xml;base64," prefix if present
    guard let data = Data(base64Encoded: base64String.replacingOccurrences(of: "data:image/svg+xml;base64,", with: "")) else {
        print("Failed to decode Base64 string.")
        return nil
    }
    
    // Initialize SVGKImage from Data
    let svgImage = SVGKImage(data: data)
    return svgImage?.uiImage
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
