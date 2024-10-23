//
//  MyViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Combine

class MyViewModel: ObservableObject {
    @Published var models: [MyModel] = []
    
    // Fetch all models from the SwiftData store
    func fetchData(modelContext: ModelContext) {
        let request = FetchDescriptor<MyModel>()
        do {
            models = try modelContext.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // Add a new model to the SwiftData store
    func addModel(title: String, modelContext: ModelContext) {
        let newModel = MyModel(title: title)
        modelContext.insert(newModel)
        saveContext(modelContext: modelContext)
        fetchData(modelContext: modelContext)
    }
    
    // Save changes to the SwiftData context
    func saveContext(modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving data: \(error)")
        }
    }
}
