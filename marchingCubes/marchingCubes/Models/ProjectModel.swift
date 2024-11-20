//
//  MyModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Foundation

@Model
class ProjectModel: Identifiable {
    var id: UUID
    var title: String
    var image: String
    var isFavorite: Bool

    init(id: UUID = UUID(), title: String, image: String, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.image = image
        self.isFavorite = isFavorite
    }
}
