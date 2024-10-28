import SwiftUI
import SwiftData

struct Dashboard: View {
    @State private var showDocumentPicker = false
    @State private var searchQuery: String = ""
    @State private var selectedModelTitle: String? = nil // Track selected model title
    @StateObject var viewModel = MyViewModel()
    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationView { // Add NavigationView here
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
                            Button(action: {
                                // Set selected model title and navigate
                                selectedModelTitle = model.title
                                print(model.title)
                            }) { // Use Button instead of NavigationLink
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
                                        // Example upload icon
                                        Image(systemName: "icloud.and.arrow.up")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeModel(model, modelContext: modelContext)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
                .padding(.horizontal)

                // Add button for new upload
                HStack {
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
            .navigationTitle("Dashboard") // Set the title for the navigation view
            .background(
                NavigationLink(destination: MarchingCubesView(filename: selectedModelTitle ?? ""), isActive: Binding<Bool>(
                    get: { selectedModelTitle != nil },
                    set: { if !$0 { selectedModelTitle = nil } }
                )) {
                    EmptyView()
                }
            )
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
