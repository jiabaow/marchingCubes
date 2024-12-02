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
    
    func fetchUserData(idToken: String) async {
        do {
            let dynamodbManager = try await DynamoDBManager()
            let userModel = await dynamodbManager.getUserModel(idToken: idToken)
            self.email = userModel?.email
            self.username = userModel?.username
            self.profileImage = userModel?.profile_image
            self.projects = userModel?.projects
            self.favorites = userModel?.favorites
        } catch(let error) {
            print("\(error)")
        }
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
