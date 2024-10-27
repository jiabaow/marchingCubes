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
            GeometryReader { geometry in
                List {
                    ForEach(viewModel.models.filter { model in
                        searchQuery.isEmpty || model.title.lowercased().contains(searchQuery.lowercased())
                    }) { model in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            Spacer()
                            // Upload button
                            Button(action: {
                                // Add your upload action here
                                print("Upload action for \(model.title)")
                            }) {
                                // Example upload icona
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 24))
                                // Change color as needed
                                    .foregroundColor(.blue)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeModel(model, modelContext: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        // Add padding for better touch area
                        .padding()
                        // White background for the item
                        .background(Color.white)
                        // Subtle shadow for depth
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10) // Change corner radius as needed
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .listRowInsets(EdgeInsets()) // Remove default row insets
                    .listRowBackground(Color.clear) // Set row background to clear
                }
                // Use PlainListStyle to remove default styling
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal)
            
            // Add button for new upload
            HStack {
                // Pushes the button to the right
                Spacer()
                
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
                .padding(.horizontal)
            }
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
