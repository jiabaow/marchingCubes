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
class UserModel: Identifiable {
    var id: String
    var email: String
    var profile_image: String
    var projects: [String]
    var favorites: [String]
    var created_timestamp: Int
    
    init(id: String, email: String, profile_image: String, projects: [String], favorites: [String], created_timestamp: Int) {
        self.id = id
        self.email = email
        self.profile_image = profile_image
        self.projects = projects
        self.favorites = favorites
        self.created_timestamp = created_timestamp
    }
}
