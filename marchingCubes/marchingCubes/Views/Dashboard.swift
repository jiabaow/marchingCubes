//
//  MyView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.

//import SwiftUI
//import SwiftData
//
//struct Dashboard: View {
//    @State private var showDocumentPicker = false
//    @State private var searchQuery: String = ""
//    @StateObject var viewModel = ProjectViewModel()
//    @Environment(\.modelContext) var modelContext
//
//    var body: some View {
//        VStack {
//            // Welcome text
//            Text("Welcome back")
//                .font(.largeTitle)
//                .padding(.top)
//
//            // Search bar
//            TextField("Search uploads...", text: $searchQuery)
//                .padding(10)
//                .background(Color(UIColor.systemGray5))
//                .cornerRadius(10)
//                .padding(.horizontal)
//
//            // Recent Creations and Uploads
//            List {
//                ForEach(viewModel.models.filter { model in
//                    searchQuery.isEmpty || model.title.lowercased().contains(searchQuery.lowercased())
//                }) { model in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(model.title)
//                                .font(.headline)
//                        }
//                        Spacer()
//                        Button(action: {
//                            viewModel.removeModel(model, modelContext: modelContext)
//                        }) {
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//            }
//
//            // Add button for new upload
//            VStack {
//                Button(action: {
//                    showDocumentPicker = true
//                }) {
//                    Text("Add Item")
//                        .padbding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//            .sheet(isPresented: $showDocumentPicker) {
//                DocumentPicker { url in
//                    saveDocumentToCache(from: url)
//                    viewModel.addModel(title: url.absoluteString, image: "", modelContext: modelContext)
//                    showDocumentPicker = false
//                }
//            }
//        }
//        .onAppear {
//            viewModel.fetchData(modelContext: modelContext)
//        }
//    }
//}
//
//struct Dashboard_Previews: PreviewProvider {
//    static var previews: some View {
//        Dashboard()
//    }
//}
import SwiftUI
import SwiftData
import UIKit

struct Dashboard: View {
    @State private var showDocumentPicker = false
    @State private var searchQuery: String = ""
    @State private var selectedModelTitle: String? = nil // Track selected model title
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Welcome text
                Text("Welcome back")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top)

                // Search bar
                TextField("Search uploads...", text: $searchQuery)
                    .padding(10)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Recent Creations
                Text("Recent Creations")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.models.prefix(2)) { model in
                        VStack {
                            Image(uiImage: UIImage(named: model.image ?? "") ?? UIImage())
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            Text(model.title)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            HStack {
                                Spacer()
                                Button(action: {
                                    if let index = viewModel.models.firstIndex(where: { $0.id == model.id }) {
                                        viewModel.models[index].isFavorite.toggle()
                                    }
                                }) {
                                    Image(systemName: model.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(model.isFavorite ? .red : .gray)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .frame(width: 120)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Uploads Section
                Text("Uploads")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading)

                List {
                    ForEach(viewModel.models.filter { model in
                        searchQuery.isEmpty || model.title.lowercased().contains(searchQuery.lowercased())
                    }) { model in
                        uploadRow(model: model)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())

                // Add button for new upload
                VStack {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Text("Add Item")
                            .font(.system(size: 18, weight: .medium))
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
                        viewModel.addModel(title: url.absoluteString, image: "", modelContext: modelContext)
                        showDocumentPicker = false
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // Extract Upload Row into a separate function
    @ViewBuilder
    private func uploadRow(model: ProjectModel) -> some View {
        NavigationLink(destination: MarchingCubesView(filename: model.title)) {
            HStack {
                // AsyncImage for loading image from URL
                if !model.image.isEmpty, let url = get3DModelURL(filename: model.image) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            // You can show a placeholder image or spinner while loading
                            ProgressView()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        case .failure:
                            // Fallback to a default image if loading fails
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Default image if model.image is nil or invalid URL
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                }
                
                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions {
            Button(role: .destructive) {
                viewModel.removeModel(model, modelContext: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
            .environmentObject(ProjectViewModel())
    }
}





// Add button for new upload
//HStack {
//    Spacer()
//    Button(action: {
//        showDocumentPicker = true
//    }) {
//        Image(systemName: "plus")
//            .font(.system(size: 24))
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .clipShape(Circle())
//            .shadow(radius: 5)
//    }
//    .padding(.bottom, 30)
//    .padding(.horizontal)
//}
//.sheet(isPresented: $showDocumentPicker) {
//    DocumentPicker { url in
//        saveDocumentToCache(from: url)
//        viewModel.addModel(title: url.absoluteString, image: "", modelContext: modelContext)
//        showDocumentPicker = false
//    }
//}
