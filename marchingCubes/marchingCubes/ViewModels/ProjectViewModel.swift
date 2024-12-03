//
//  MyViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Combine
import Foundation
import SwiftUICore

class ProjectViewModel: ObservableObject {
    @Published var models: [ProjectModel] = []
    
    // autoload all files in
    init() {
        models = []
        if let fileUrls = getCachedFiles() {
            for fileUrl in fileUrls {
                if (fileUrl.lastPathComponent.hasSuffix(".obj")) {
                    let projModel = ProjectModel(id: NSUUID() as UUID, title: fileUrl.lastPathComponent, image: "\(fileUrl.lastPathComponent).png")
                    if (!self.models.contains(projModel)) {
                        self.models.append(projModel)
                    }
                }
            }
        }
    }
    
    // Add a func to toggle favorite status
    func toggleFavorite(for model: ProjectModel) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index].isFavorite.toggle()
        }
    }
    
    // Fetch all models from the SwiftData store
    func fetchData(modelContext: ModelContext) {
        let request = FetchDescriptor<ProjectModel>()
        do {
            models = try modelContext.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    // Add a new model to the SwiftData store
    func addModel(title: String, image: String, modelContext: ModelContext) {
        if models.contains(where: { $0.title == title }) {
            print("Model with title '\(title)' already exists. Skipping addition.")
            return
        }
        
        let newModel = ProjectModel(title: title, image: image)
        if (models.contains(newModel)) {
            print("Model with title: \(title) already exists")
            return
        }
        modelContext.insert(newModel)
        models.append(newModel)
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

    func removeModel(_ model: ProjectModel, modelContext: ModelContext) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models.remove(at: index)
            // removes from real filesystem in cache
            if let url = get3DModelURL(filename: model.title), let urlimage = get3DModelURL(filename: model.image) {
                removeFile(at: url)
                removeFile(at: urlimage)
            } else {
                // Handle invalid URL case if needed
                print("Invalid URL string: \(model.title)")
                print("Invalid URL string: \(model.image)")
            }
            
            modelContext.delete(model) // Remove from context
        }
    }
}
