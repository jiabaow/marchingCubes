//
//  DynamoDBManager.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/7/24.
//

import Foundation
import AWSClientRuntime
import AWSDynamoDB

class DynamoDBManager {
    
    let dynamoDB: AWSDynamoDB.DynamoDBClient
    
    init() async throws {
//        let credentialsProvider = AWSClientRuntime.(accessKey: ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"],
//                                                               secretKey: ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"])
        do {
            let config = try await DynamoDBClient.DynamoDBClientConfiguration(region: "us-east-2")
            self.dynamoDB = AWSDynamoDB.DynamoDBClient(config: config)
        } catch {
            print("Error: ", dump(error, name: "Initializing Amazon DynamoDBClient client"))
            throw error
        }
    }
    
    func createTable() async throws {
            do {
                let client = self.dynamoDB

                let input = CreateTableInput(
                    attributeDefinitions: [
                        DynamoDBClientTypes.AttributeDefinition(attributeName: "year", attributeType: .n),
                        DynamoDBClientTypes.AttributeDefinition(attributeName: "title", attributeType: .s)
                    ],
                    keySchema: [
                        DynamoDBClientTypes.KeySchemaElement(attributeName: "year", keyType: .hash),
                        DynamoDBClientTypes.KeySchemaElement(attributeName: "title", keyType: .range)
                    ],
                    provisionedThroughput: DynamoDBClientTypes.ProvisionedThroughput(
                        readCapacityUnits: 10,
                        writeCapacityUnits: 10
                    ),
                    tableName: "movies"
                )
                let output = try await client.createTable(input: input)
                if output.tableDescription == nil {
                    print("error: in tble")
                    return
                }
            } catch {
                if error is TableAlreadyExistsException {
                    print("table already exists")
                    return;
                }
                print("ERROR: createTable:", dump(error))
                throw error
            }
        }

    
    func getUserAsItem(userModel: UserModel) async throws -> [Swift.String:DynamoDBClientTypes.AttributeValue]  {
        // Convert each project and favorite to a DynamoDB AttributeValue
        let projectsAttributeValue = userModel.projects.map { DynamoDBClientTypes.AttributeValue.s($0) }
        let favoritesAttributeValue = userModel.favorites.map { DynamoDBClientTypes.AttributeValue.s($0) }

        let item: [Swift.String:DynamoDBClientTypes.AttributeValue] = [
            "id": .s(userModel.id),
            "email": .s(userModel.email),
            "profile_image": .s(userModel.profile_image),
            "projects": .l(projectsAttributeValue),
            "favorites": .l(favoritesAttributeValue),
            "created_timestamp": .n(String(userModel.created_timestamp))
        ]

        return item
    }
    
    func insertUserModel(userModel: UserModel) async throws {
        let client = self.dynamoDB
        
        // Convert UserModel to a dictionary
        do {
            let dynamoItem = try await getUserAsItem(userModel: userModel)
            let input = PutItemInput(
                item: dynamoItem,
                tableName: "marchingcubes"
                )
            _ = try await client.putItem(input: input)
        } catch {
            print("Error insertUserModel: ", dump(error))
            throw error
        }
    }
}

// Usage
//let userModel = UserModel(id: "123", email: "john.doe@example.com", profile_image: "profile.png", projects: ["proj1", "proj2"], favorites: ["fav1", "fav2"], created_timestamp: Int(Date().timeIntervalSince1970))
//let dynamoDBManager = DynamoDBManager()
//dynamoDBManager.insertUserModel(userModel: userModel)
