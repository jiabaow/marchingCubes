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
               let secretKey = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"],
               let sessionToken = ProcessInfo.processInfo.environment["AWS_SESSION_TOKEN"] {
                awsCred = AWSCredentialIdentity(
                    accessKey: accessKeyId,
                    secret: secretKey,
                    expiration: nil,
                    sessionToken: sessionToken
                )
//                print("AWS Access Key: \(accessKeyId)")
//                print("AWS Secret Key: \(secretKey)")
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
    
    func insertUserModel(userModel: UserModel) async -> Bool {
        let client = self.dynamoDB
        
        // Convert UserModel to a dictionary
        do {
            let dynamoItem = try await getUserAsItem(userModel: userModel)
            let input = PutItemInput(
                item: dynamoItem,
                tableName: "marchingcubesusers"
            )
            _ = try await client.putItem(input: input)
        } catch {
            print("Error insertUserModel: ", dump(error))
            return false
        }
        return true
    }
    
    func getUserModel(idToken: String) async -> UserModel? {
        let client = self.dynamoDB
        
        do {
            let arr = idToken.split(separator: ":", maxSplits: 1)
            let token = arr[0]
            let username = arr[1]
            
            let input = GetItemInput(
                key: [
                    "id": .s(String(token)),
                    "email": .s(String(username))
                ],
                tableName: "marchingcubesusers"
            )
            
            let output = try await client.getItem(input: input)
            guard let item = output.item else {
                print("Unable to get user information from \(idToken)")
                return nil
            }
            
            let userModel = try UserModel(from: item)
            return userModel
        } catch(let error) {
            print("\(error)")
        }
        return nil
    }
    
    func putUserModel(idToken: String) async -> Bool {
        return true
    }
}


func extractSubFromIDToken(_ idToken: String) -> String? {
    // Split the JWT into its three parts
    let segments = idToken.split(separator: ".")
    guard segments.count == 3 else {
        print("Invalid JWT format")
        return nil
    }
    
    // Get the payload segment (second part of the JWT)
    let payloadSegment = segments[1]
    
    // Add padding if necessary
    var base64String = String(payloadSegment)
        .replacingOccurrences(of: "-", with: "+") // URL-safe to standard Base64
        .replacingOccurrences(of: "_", with: "/") // URL-safe to standard Base64
    while base64String.count % 4 != 0 { // Add padding if necessary
        base64String.append("=")
    }
    
    // Decode the Base64 payload
    guard let payloadData = Data(base64Encoded: base64String) else {
        print("Failed to decode Base64")
        return nil
    }
    
    // Convert to JSON and extract the `sub` field
    do {
        if let payloadJson = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
           let subValue = payloadJson["sub"] as? String {
            return subValue
        } else {
            print("Failed to parse JSON or find 'sub' key")
            return nil
        }
    } catch {
        print("Failed to parse JSON: \(error)")
        return nil
    }
}

func dynamoAttrToPrimitive(_ attributeValue: DynamoDBClientTypes.AttributeValue) -> Any? {
        switch attributeValue {
        case .s(let stringValue):
            return stringValue
        case .n(let numberValue):
            return Int(numberValue) ?? Double(numberValue) ?? numberValue // Attempt to parse as Int, Double, or leave as a string
        case .b(let dataValue):
            return dataValue
        case .bool(let boolValue):
            return boolValue
        case .l(let listValue):
            return listValue.compactMap { dynamoAttrToPrimitive($0) }
        case .m(let mapValue):
            return mapValue.reduce(into: [String: Any]()) { (result, pair) in
                result[pair.key] = dynamoAttrToPrimitive(pair.value)
            }
        case .ss(let stringSet):
            return Array(stringSet)
        case .bs(let binarySet):
            return binarySet
        default:
            return nil // Handle cases like null or unknown types
        }
    }

// Usage
//let userModel = UserModel(id: "123", email: "john.doe@example.com", profile_image: "profile.png", projects: ["proj1", "proj2"], favorites: ["fav1", "fav2"], created_timestamp: Int(Date().timeIntervalSince1970))
//let dynamoDBManager = DynamoDBManager()
//dynamoDBManager.insertUserModel(userModel: userModel)
