//
//  MyViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Combine
import Foundation

class ProjectViewModel: ObservableObject {
    @Published var models: [ProjectModel] = []
    
    // autoload all files in
    init() {
        if let fileUrls = getCachedFiles() {
            for fileUrl in fileUrls {
//                print("filename init load: \(fileUrl.lastPathComponent)")
                if (fileUrl.lastPathComponent.hasSuffix(".obj")) {
                    self.models.append(ProjectModel(id: NSUUID() as UUID, title: fileUrl.lastPathComponent, image: "\(fileUrl.lastPathComponent).png"))
                }
            }
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
        let newModel = ProjectModel(title: title, image: image)
        modelContext.insert(newModel)
        models.append(newModel)
        saveContext(modelContext: modelContext)
        fetchData(modelContext: modelContext)
        print(models)
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
