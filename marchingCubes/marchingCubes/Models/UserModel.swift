//
//  UploadModel.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/27/24.
//
import SwiftData
import Foundation
import AWSDynamoDB

@Model
class UserModel: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var profile_image: String
    var projects: [String]
    var favorites: [String]
    var created_timestamp: Int
    
    init(id: String, email: String, username: String, profile_image: String, projects: [String], favorites: [String], created_timestamp: Int) {
        self.id = id
        self.username = username
        self.email = email
        self.profile_image = profile_image
        self.projects = projects
        self.favorites = favorites
        self.created_timestamp = created_timestamp
    }
    
    // TODO:: Build an Encoder and Decoder for AWS DynamoDB Attributes
    // Encode to DynamoDB attributes
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(username, forKey: .username)
        try container.encode(profile_image, forKey: .profile_image)
        try container.encode(projects, forKey: .projects)
        try container.encode(favorites, forKey: .favorites)
        try container.encode(created_timestamp, forKey: .created_timestamp)
    }
    
    // Custom Decoding (if needed)
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        profile_image = try container.decode(String.self, forKey: .profile_image)
        projects = try container.decode([String].self, forKey: .projects)
        favorites = try container.decode([String].self, forKey: .favorites)
        created_timestamp = try container.decode(Int.self, forKey: .created_timestamp)
    }
    
    // CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case profile_image
        case projects
        case favorites
        case created_timestamp
    }
    
    required init(from item: [Swift.String:DynamoDBClientTypes.AttributeValue]) throws {
        guard let idAttr = item["id"],
              let emailAttr = item["email"] else {
            throw NSError(domain: "UserModel.decode", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot get id nor email"])
        }
        self.id = dynamoAttrToPrimitive(idAttr) as! String
        self.email = dynamoAttrToPrimitive(emailAttr) as! String
        
        let userName = item["username"]!
        self.username = dynamoAttrToPrimitive(userName) as! String
        
        let profileImage = item["profile_image"]!
        self.profile_image = dynamoAttrToPrimitive(profileImage) as! String
        
        let projects = item["projects"]!
        self.projects = dynamoAttrToPrimitive(projects) as! [String]
        
        let favorites = item["favorites"]!
        self.favorites = dynamoAttrToPrimitive(favorites) as! [String]
        
        let createdTimeStamp = item["created_timestamp"]!
        self.created_timestamp = dynamoAttrToPrimitive(createdTimeStamp) as! Int
    }
    
    func fetchUserData(idToken: String) async throws {
        do {
            let dynamodbManager = try await DynamoDBManager()
            guard let userModel = await dynamodbManager.getUserModel(idToken: idToken) else {
                throw NSError(domain: "UserModel", code: -1, userInfo: ["fetchUserData": "User not found."])
            }
            
            DispatchQueue.main.async {
                self.id = userModel.id
                self.email = userModel.email
                self.username = userModel.username
                self.profile_image = userModel.profile_image
                self.projects = userModel.projects
                self.favorites = userModel.favorites
                self.created_timestamp = userModel.created_timestamp
            }
            
        } catch(let error) {
            print("\(error)")
            throw NSError(domain: "UserModel", code: -1, userInfo: ["fetchUserData": "\(error)"])
        }
    }
}
