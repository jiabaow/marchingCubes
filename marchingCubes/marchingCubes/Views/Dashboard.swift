//
//  MyView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.

import SwiftUI
import SwiftData

struct Dashboard: View {
    @State private var showDocumentPicker = false
    @State private var searchQuery: String = ""
    @StateObject var viewModel = MyViewModel()
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            // Welcome text
            Text("Welcome back")
                .font(.largeTitle)
                .padding(.top)

            // Search bar
            TextField("Search uploads...", text: $searchQuery)
                .padding(10)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
                .padding(.horizontal)

            // Recent Creations and Uploads
            List {
                ForEach(viewModel.models.filter { model in
                    searchQuery.isEmpty || model.title.lowercased().contains(searchQuery.lowercased())
                }) { model in
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

            // Add button for new upload
            VStack {
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Text("Add Item")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    saveDocumentToCache(from: url)
                    viewModel.addModel(title: url.absoluteString, modelContext: modelContext)
                    showDocumentPicker = false
                }
            }
        }
        .onAppear {
            viewModel.fetchData(modelContext: modelContext)
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
