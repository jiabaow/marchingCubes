//
//  MyView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
    @State private var showDocumentPicker = false
    @StateObject var viewModel = MyViewModel()  // ViewModel instance
    @Environment(\.modelContext) var modelContext  // Access the SwiftData context
    
    @State private var title: String = ""
    
    var body: some View {
        VStack {
            
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
            
            // Form to add a new item
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
                DocumentPicker {
                    url in
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

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
