//
//  DocumentPicker.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard controller.documentPickerMode == .open, let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            defer {
                DispatchQueue.main.async {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            do {
                if let selectedFile = urls.first {
                    let document = try Data(contentsOf: selectedFile.absoluteURL)
                    
                    let fileManager = FileManager.default
                    
                    // Get the Documents directory
                    let documentsURL = try fileManager.url(
                        for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    ).appendingPathComponent(selectedFile.lastPathComponent)
                    
                    try document.write(to: documentsURL)
                    parent.onFilePicked(documentsURL)
                }
            } catch (let error) {
                print("Error opening file \(error).")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
        }
    }

    var onFilePicked: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let objUTType = UTType(filenameExtension: "obj") ?? UTType.data
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [objUTType])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
