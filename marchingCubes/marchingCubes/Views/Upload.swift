//
//  Upload.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//
import Foundation

import SwiftUI

struct Upload: View {
    @State private var selectedFileURL: URL?
    @State private var showDocumentPicker = false
    @State private var selectedFileText: String = ""
    // ViewModel instance
    @StateObject var viewModel = MyViewModel()
    // Access the SwiftData context
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            // Upload title
            Text("Upload Your File")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Tappable RoundedRectangle for Upload Image
            ZStack {
                // View with a dashed border
                RoundedRectangle(cornerRadius: 10)
                // Dashed stroke
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                // Adjust size as needed
                .frame(height: 200)
                .foregroundColor(.gray)
                .overlay(
                    Text("Choose file (.obj)")
                        .foregroundColor(.gray)
                )
                .padding(.horizontal)
                .padding(.top)
                .onTapGesture {
                    showDocumentPicker = true
                }

                if let url = selectedFileURL {
                    Text("Selected File: \(url.lastPathComponent)")
                        .padding(.bottom, 15)
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker {
                    url in
                    self.selectedFileURL = url
                    saveDocumentToCache(from: url)
                    viewModel.addModel(title: url.absoluteString, modelContext: modelContext)
                    showDocumentPicker = false
                }
            }

            // The new cached files list view
            List {
                ForEach(viewModel.models) { model in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(model.title)
                                .font(.headline)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.removeModel(model, modelContext: modelContext)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
    }
}

struct Upload_Previews: PreviewProvider {
    static var previews: some View {
        Upload()
    }
}
