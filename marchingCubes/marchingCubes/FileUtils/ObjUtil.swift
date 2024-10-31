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

// Save the image to cache
func saveImageToCache(_ image: UIImage, _ filename: String) -> Bool {
    guard let data = image.pngData() else { return false; }
    guard let filedir = get3DFilesDirectory() else {
        print("3dFiles directory not found")
        return false
    }
    let fileURL = filedir.appendingPathComponent("\(filename).png")
    do {
        try data.write(to: fileURL)
        print("Screenshot saved to cache: \(fileURL.lastPathComponent)")
        return true;
    } catch {
        print("Error saving screenshot: \(error)")
        return false;
    }
}

// 3. Save the screenshot to the app's cache directory
//func saveImageToCache(_ image: UIImage, _ fileName: String) {
//    let fileManager = FileManager.default
//    if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
//        let fileURL = cacheDirectory.appendingPathComponent("\(fileName).png")
//
//        if let imageData = image.pngData() {
//            do {
//                try imageData.write(to: fileURL)
//                print("Image saved to cache at: \(fileURL)")
//            } catch {
//                print("Error saving image to cache: \(error)")
//            }
//        }
//    }
//}


func get3DModelURL(filename: String) -> URL? {
    // Get the 3D files directory
    guard let directory = get3DFilesDirectory() else {
        print("Could not get 3D files directory.")
        return nil
    }
    
    let assetUrl = directory.appendingPathComponent(filename)
    
    // Check if the file exists
    if !FileManager.default.fileExists(atPath: assetUrl.path) {
        print("File does not exist at path: \(assetUrl.path)")
        return nil
    }
    
    // Create the full file URL
    return directory.appendingPathComponent(filename)
}

func loadObjAsset(filename: URL) -> MDLAsset? {
    print("Loading model from: \(filename.path)")
    
    // Check if the file exists
    if !FileManager.default.fileExists(atPath: filename.path) {
        print("File does not exist at path: \(filename.path)")
        return nil
    } else {
        print("File \(filename.lastPathComponent) exists.")
    }
    
    // Check if file can be imported
    print(MDLAsset.canImportFileExtension(filename.lastPathComponent))
    
    let asset = MDLAsset(url: filename)
    if asset.count > 0 {
        return asset
    } else {
        print("Failed to create MDLAsset from URL: \(filename.lastPathComponent)")
        return nil
    }
}


