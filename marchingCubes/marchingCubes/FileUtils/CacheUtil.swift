//
//  CacheUtil.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//
import Foundation
import SceneKit

// Helper function to get the 3dFiles directory inside the app's directory
func get3DFilesDirectory() -> URL? {
    let fileManager = FileManager.default

    // Get the app's documents directory
    if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let threeDFilesDirectory = documentsDirectory.appendingPathComponent("3dFiles")

        // Create the 3dFiles directory if it doesn't exist
        if !fileManager.fileExists(atPath: threeDFilesDirectory.path) {
            do {
                try fileManager.createDirectory(at: threeDFilesDirectory, withIntermediateDirectories: true)
                print("Created 3dFiles directory at: \(threeDFilesDirectory)")
            } catch {
                print("Error creating 3dFiles directory: \(error)")
                return nil
            }
        }
        return threeDFilesDirectory
    }
    return nil
}

// Function to check if a file exists in the 3dFiles directory
func fileExistsIn3DFiles(filename: String) -> Bool {
    guard let threeDFilesDirectory = get3DFilesDirectory() else {
        print("3dFiles directory not found")
        return false
    }

    let fileURL = threeDFilesDirectory.appendingPathComponent(filename)
    return FileManager.default.fileExists(atPath: fileURL.path)
}

// Save the image to cache
private func saveImageToCache(_ image: UIImage, _ filename: String) -> Bool {
    guard let data = image.pngData() else { return false; }
    guard let filedir = get3DFilesDirectory() else {
        print("3dFiles directory not found")
        return false
    }
    let fileURL = filedir.appendingPathComponent(filename)
    do {
        try data.write(to: fileURL)
        print("Screenshot saved to cache: \(filename)")
        return true;
    } catch {
        print("Error saving screenshot: \(error)")
        return false;
    }
}

func getCachedFiles() -> [URL]? {
    let fileManager = FileManager.default

    if let cacheDirectory = get3DFilesDirectory() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("Error retrieving cached files: \(error)")
        }
    }
    return nil
}

func removeFile(at url: URL) {
    let fileManager = FileManager.default

    do {
        try fileManager.removeItem(at: url)
        print("File removed: \(url)")
    } catch {
        print("Error removing file: \(error)")
    }
}

func saveDocumentToCache(from url: URL) {
    let fileManager = FileManager.default

    if let cacheDirectory = get3DFilesDirectory() {
        let cachedFileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        print(cachedFileURL.absoluteString)
        // Remove existing file if it exists
        try? fileManager.removeItem(at: cachedFileURL)

        do {
            // Copy the file to the 3dFiles directory
            try fileManager.copyItem(at: url, to: cachedFileURL)
            print("File saved to 3dFiles at: \(cachedFileURL)")
        } catch {
            print("Error saving file to 3dFiles: \(error)")
        }
    }
}

