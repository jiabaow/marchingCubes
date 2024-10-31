//
//  ObjUtil.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/28/24.
//
import SceneKit
import UIKit

// 1. Load the 3D model from the .obj file
func loadModel() -> SCNScene? {
    guard let scene = try? SCNScene(named: "model.obj") else {
        print("Failed to load the .obj file")
        return nil
    }
    return scene
}

// 2. Capture a screenshot of the view displaying the model
func takeScreenshot(of view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
    defer { UIGraphicsEndImageContext() }
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    return UIGraphicsGetImageFromCurrentImageContext()
}

// 3. Save the screenshot to the app's cache directory
func saveImageToCache(_ image: UIImage, _ fileName: String) {
    let fileManager = FileManager.default
    if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
        let fileURL = cacheDirectory.appendingPathComponent("\(fileName).png")

        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL)
                print("Image saved to cache at: \(fileURL)")
            } catch {
                print("Error saving image to cache: \(error)")
            }
        }
    }
}
