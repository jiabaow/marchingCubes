/*
//  MyView.swift
//  marchingCubes
//  Created by 温嘉宝 on 22.10.2024.
*/
import SwiftUI
import SwiftData
import UIKit

struct Dashboard: View {
    @State private var division: Double = 5.0
    @State private var colorScheme: ColorScheme = .scheme1
    @State private var showDivisionSlider = false
    @State private var navigateToMarchingCubes = false
    @State private var showAddModelView = false
    @State private var showDocumentPicker = false
    @State private var searchQuery: String = ""
    @State private var selectedModelTitle: String? = nil // Track selected model title
    @State private var selectedModel: ProjectModel? = nil
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
                TextField("Search Models...", text: $searchQuery)
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
                        ForEach(viewModel.models.suffix(10).reversed(), id: \.self) { model in
                            Button(action: {
                                showDivisionSlider = true
                                selectedModelTitle = model.title
                            }) {
                                VStack {
                                    // AsyncImage for loading image from URL
                                    if !model.image.isEmpty, let url = get3DModelURL(filename: model.image) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                // Placeholder image or spinner while loading
                                                ProgressView()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            case .failure:
                                                // Fallback to a default image if loading fails
                                                Image(systemName: "cube")
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        // Default image if model.image is nil or invalid URL
                                        Image(systemName: "photo")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                    }
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
                                .padding()
                                .background(Color(hex: "E5E6F6")) // Light purple background color
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Add shadow
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                // Uploads Section
                Text("Models")
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
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.fetchData(modelContext: modelContext)
            }
        } // Navigation View
    }

    @ViewBuilder
    private func uploadRow(model: ProjectModel) -> some View {
        HStack {
            // AsyncImage for loading image from URL
            if !model.image.isEmpty, let url = get3DModelURL(filename: model.image) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
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
                        Image(systemName: "cube")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(5)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
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
            
            // Button to show the division slider
            Button(action: {
                showDivisionSlider = true
                selectedModelTitle = model.title
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            
            if navigateToMarchingCubes {
                NavigationLink(
                    destination: MarchingCubesView(filename: selectedModelTitle!, divisions: Int(division), colorScheme: colorScheme),
                    isActive: $navigateToMarchingCubes
                ) {
                    EmptyView()
                }
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .sheet(isPresented: $showDivisionSlider) {
            DivisionSliderView(division: $division, selectedScheme: $colorScheme) {
                showDivisionSlider = false
                navigateToMarchingCubes = true
            }.onAppear {
                print("\(selectedModelTitle)")
            }
        }
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

// Color extension to use hex codes
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
