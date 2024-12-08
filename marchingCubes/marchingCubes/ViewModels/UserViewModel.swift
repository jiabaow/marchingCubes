//
//  UserViewModel.swift
//  marchingCubes
//
//  Created by Charles Weng on 12/1/24.
//
import Foundation

class UserViewModel: ObservableObject {
//    @Published var id: String
    @Published var email: String?
    @Published var username: String?
    @Published var profileImage: String?
    @Published var projects: [String]?
    @Published var favorites: [String]?
//    @Published var createdTimestamp: Int?
    
    init() {
        self.email = nil
        self.username = nil
        self.profileImage = nil
        self.projects = nil
        self.favorites = nil
    }
    
    @MainActor
    func fetchUserData(idToken: String, userToken: String = "") async throws {
        var dynamodbMan: DynamoDBManager? = nil
        do {
            dynamodbMan = try await DynamoDBManager()
        } catch (let error) {
            print("Error with default access keys: \(error).")
            do {
                dynamodbMan = try await DynamoDBManager(userToken: userToken)
            } catch (let error) {
                print("Error with cached token key: \(error).")
                throw NSError(domain: "UserViewModel", code: -1, userInfo: ["fetchUserData": "\(error)"])
            }
        }
        
        guard let dynamodbManager = dynamodbMan else {
            throw NSError(domain: "UserViewModel", code: -1, userInfo: ["fetchUserData": "Cannot initialize dynamodb due to credential issues."])
        }
        
        let userModel = await dynamodbManager.getUserModel(idToken: idToken)
        self.email = userModel?.email
        self.username = userModel?.username
        self.profileImage = userModel?.profile_image
        self.projects = userModel?.projects
        self.favorites = userModel?.favorites
    }
    
    // Computed property for formatted date
//    var formattedCreationDate: String {
//        let date = Date(timeIntervalSince1970: TimeInterval(createdTimestamp))
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
    
    // Dependency on the UserModel
//    private var userModel: UserModel
    
    init(userModel: UserModel) {
//        self.userModel = userModel
//        self.id = userModel.id
        self.email = userModel.email
        self.username = userModel.username
        self.profileImage = userModel.profile_image
        self.projects = userModel.projects
        self.favorites = userModel.favorites
//        self.createdTimestamp = userModel.created_timestamp
    }
    
    // Method to update the user model
    func updateEmail(newEmail: String) {
        email = newEmail
    }
    
    func updateUsername(newUsername: String) {
        username = newUsername
    }
    
    func addProject(projectId: String) {
        guard var projects = self.projects else {
            print("Failed to add project to User Model.")
            return
        }
        projects.append(projectId)
    }
    
    func addFavorite(projectId: String) {
        guard var favorites = self.favorites else {
            print("Failed to add favorites to User Model.")
            return
        }
        favorites.append(projectId)
    }
}
