//
//  CacheUtil.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//

import Foundation

func getCachedFiles() -> [URL]? {
    let fileManager = FileManager.default
    if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
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
    } catch {
        print("Error removing file: \(error)")
    }
}

// Function to save the document to the cache directory
func saveDocumentToCache(from url: URL) {
    let fileManager = FileManager.default

    // Create a cache directory URL
    if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
        let cachedFileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        // Remove existing file if it exists
        try? fileManager.removeItem(at: cachedFileURL)

        do {
            // Copy the file to the cache directory
            try fileManager.copyItem(at: url, to: cachedFileURL)
            print("File saved to cache at: \(cachedFileURL)")
        } catch {
            print("Error saving file to cache: \(error)")
        }
    }
}
