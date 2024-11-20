//
//  ProfileView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//
import SwiftUI

struct ProfileView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("isDarkMode") static var isDarkMode = false // State for Dark Mode
    @State private var avatarImage: UIImage? = nil
    @State private var userName: String = "Peter Johnson" // Mock data for the user name
    @State private var projects: [ProjectModel] = [] // Array of projects

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dark Mode Toggle Button
                HStack {
                    Spacer()
                    Button(action: {
                        ProfileView.isDarkMode.toggle()
                    }) {
                        Image(systemName: ProfileView.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(ProfileView.isDarkMode ? .yellow : .blue)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 20)
                
                // User avatar and name
                VStack {
                    if let avatarImage = avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    }

                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)

                // My Favorites section
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Favorites")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(projects.filter { $0.isFavorite }, id: \.id) { project in
                                VStack {
                                    if let image = UIImage(named: project.image) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                    }
                                    Text(project.title)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .background(ProfileView.isDarkMode ? Color.black : Color.white)
            .onAppear {
                loadUserData()
            }
        }
        .preferredColorScheme(ProfileView.isDarkMode ? .dark : .light) // Set the color scheme
    }

    private func loadUserData() {
        // Simulate fetching user data
        self.userName = "Peter Johnson" // Example data
        self.projects = [
            ProjectModel(title: "Project 1", image: "placeholder", isFavorite: true),
            ProjectModel(title: "Project 2", image: "placeholder", isFavorite: false),
            ProjectModel(title: "Project 3", image: "placeholder", isFavorite: true)
        ] // Replace with real data
        self.avatarImage = UIImage(named: "placeholder") // Replace with actual image loading logic
    }

    func signOut() {
        isAuthenticated = false
        print("User signed out")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
