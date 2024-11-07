//
//  DynamoDBManager.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/7/24.
//

import Foundation
import AWSDynamoDB

class DynamoDBManager {
    
    let dynamoDB: AWSDynamoDB.DynamoDBClient
    
    init() throws {
        self.dynamoDB = try AWSDynamoDB.DynamoDBClient(region: "us-east-2")
    }
    
    func getUserAsItem(userModel: UserModel) async throws -> [Swift.String:DynamoDBClientTypes.AttributeValue]  {
            // Build the item record, starting with the year and title, which are
            // always present.
            // Convert each project and favorite to a DynamoDB AttributeValue
            let projectsAttributeValue = userModel.projects.map { DynamoDBClientTypes.AttributeValue.s($0) }
            let favoritesAttributeValue = userModel.favorites.map { DynamoDBClientTypes.AttributeValue.s($0) }

            var item: [Swift.String:DynamoDBClientTypes.AttributeValue] = [
                "id": .s(userModel.id),
                "email": .s(userModel.email),
                "projects": .l(projectsAttributeValue),
                "favorites": .l(favoritesAttributeValue)
            ]

            // Add the `info` field with the rating and/or plot if they're
            // available.

            var details: [Swift.String:DynamoDBClientTypes.AttributeValue] = [:]
//            if (self.info.rating != nil || self.info.plot != nil) {
//                if self.info.rating != nil {
//                    details["rating"] = .n(String(self.info.rating!))
//                }
//                if self.info.plot != nil {
//                    details["plot"] = .s(self.info.plot!)
//                }
//            }
            item["info"] = .m(details)

            return item
        }
    
    func insertUserModel(userModel: UserModel) async throws {
        let client = self.dynamoDB
        
        // Convert UserModel to a dictionary
//        let item: [String: AWSDynamoDBAttributeValue] = [
//            "id": AWSDynamoDBAttributeValue(s: userModel.id),
//            "email": AWSDynamoDBAttributeValue(s: userModel.email),
//            "profile_image": AWSDynamoDBAttributeValue(s: userModel.profile_image),
//            "projects": AWSDynamoDBAttributeValue(ss: userModel.projects),
//            "favorites": AWSDynamoDBAttributeValue(ss: userModel.favorites),
//            "created_timestamp": AWSDynamoDBAttributeValue(n: "\(userModel.created_timestamp)")
//        ]
        
//        let input = AWSDynamoDBPutItemInput()
//        input?.tableName = "YourDynamoDBTableName" // Replace with your table name
//        input?.item = item
//        
//        dynamoDB.putItem(input!) { (output, error) in
//            if let error = error {
//                print("Failed to save object to DynamoDB: \(error.localizedDescription)")
//            } else {
//                print("Successfully saved object to DynamoDB.")
//            }
//        }
    }
}

// Usage
//let userModel = UserModel(id: "123", email: "john.doe@example.com", profile_image: "profile.png", projects: ["proj1", "proj2"], favorites: ["fav1", "fav2"], created_timestamp: Int(Date().timeIntervalSince1970))
//let dynamoDBManager = DynamoDBManager()
//dynamoDBManager.insertUserModel(userModel: userModel)
