//
//  MyViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Combine
import Foundation

class MyViewModel: ObservableObject {
    @Published var models: [MyModel] = []
    
    init() {
        if let fileUrls = getCachedFiles() {
            for fileUrl in fileUrls {
                self.models.append(MyModel(id: NSUUID() as UUID, title: fileUrl.absoluteString))
            }
        }
    }

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

    func removeModel(_ model: MyModel, modelContext: ModelContext) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models.remove(at: index)
            /*
            removes from real filesystem
            if let url = URL(string: model.title) {
                removeFile(at: url)
            } else {
                // Handle invalid URL case if needed
                print("Invalid URL string: \(model.title)")
            }
            */
            modelContext.delete(model) // Remove from context
        }
    }
}
