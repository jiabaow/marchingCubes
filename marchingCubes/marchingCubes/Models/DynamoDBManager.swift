//
//  DynamoDBManager.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/7/24.
//

import Foundation
import AWSClientRuntime
import AWSDynamoDB
import AwsCommonRuntimeKit
import AWSSDKIdentity

class DynamoDBManager {
    
    let dynamoDB: AWSDynamoDB.DynamoDBClient
    
    init() async throws {
        do {
            var awsCred: AWSCredentialIdentity? = nil
//            let creds = (CredentialsProvider.Source.static(accessKey: ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"]!, secret: ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"]!))
            if let accessKeyId = ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"],
               let secretKey = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] {
                awsCred = AWSCredentialIdentity(
                    accessKey: accessKeyId,
                    secret: secretKey,
                    expiration: nil,
                    sessionToken: nil
                )
                print("AWS Access Key: \(accessKeyId)")
                print("AWS Secret Key: \(secretKey)")
            } else {
                print("Cannot find AWS keys.")
                throw NSError(domain: "Cannot find AWS keys.", code: -1)
            }
            
            
            // Create a custom credentials identity resolver
            let staticResolver = try StaticAWSCredentialIdentityResolver(
                awsCred!
            )
            
            let config = try await DynamoDBClient.DynamoDBClientConfiguration(
                awsCredentialIdentityResolver: staticResolver,
                region: "us-east-2"
            )
                        
            self.dynamoDB = AWSDynamoDB.DynamoDBClient(config: config)
        } catch {
            print("Error: ", dump(error, name: "Initializing Amazon DynamoDBClient client"))
            throw error
        }
    }
    
    func createTable() async {
        do {
            let client = self.dynamoDB
            
            let input = CreateTableInput(
                attributeDefinitions: [
                    DynamoDBClientTypes.AttributeDefinition(attributeName: "id", attributeType: .s),
                    DynamoDBClientTypes.AttributeDefinition(attributeName: "email", attributeType: .s)
                ],
                keySchema: [
                    DynamoDBClientTypes.KeySchemaElement(attributeName: "id", keyType: .hash),
                    DynamoDBClientTypes.KeySchemaElement(attributeName: "email", keyType: .range)
                ],
                provisionedThroughput: DynamoDBClientTypes.ProvisionedThroughput(
                    readCapacityUnits: 10,
                    writeCapacityUnits: 10
                ),
                tableName: "marchingcubesusers"
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
        }
    }
    
    
    func getUserAsItem(userModel: UserModel) async throws -> [Swift.String:DynamoDBClientTypes.AttributeValue]  {
        // Convert each project and favorite to a DynamoDB AttributeValue
        let projectsAttributeValue = userModel.projects.map { DynamoDBClientTypes.AttributeValue.s($0) }
        let favoritesAttributeValue = userModel.favorites.map { DynamoDBClientTypes.AttributeValue.s($0) }
        
        let item: [Swift.String:DynamoDBClientTypes.AttributeValue] = [
            "id": .s(userModel.id),
            "email": .s(userModel.email),
            "username": .s(userModel.username),
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
