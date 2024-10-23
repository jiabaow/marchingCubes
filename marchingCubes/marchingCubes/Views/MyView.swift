//
//  MyView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI
import SwiftData

struct MyView: View {
    @StateObject var viewModel = MyViewModel()  // ViewModel instance
    @Environment(\.modelContext) var modelContext  // Access the SwiftData context
    
    @State private var title: String = ""
    
    var body: some View {
        VStack {
            List(viewModel.models) { model in
                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.headline)
                }
            }
            
            // Form to add a new item
            VStack {
                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    viewModel.addModel(title: title, modelContext: modelContext)
                    title = ""
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
        }
        .onAppear {
            viewModel.fetchData(modelContext: modelContext)
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
    }
}
