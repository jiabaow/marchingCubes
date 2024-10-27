//
//  UploadModel.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/27/24.
//

import Foundation

import SwiftData
import Foundation

@Model
class UploadModel: Model {
    var id: UUID
    var title: String
    
    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}
