//
//  ProfileView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI
import UIKit


struct ProfileView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("isDarkMode") static var isDarkMode = false
    @EnvironmentObject var viewModel: ProjectViewModel
    @State private var avatarImage: UIImage? = nil
    @State private var userName: String = "Peter Johnson"

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
                            ForEach(viewModel.models.filter { $0.isFavorite }, id: \.id) { project in
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
        .preferredColorScheme(ProfileView.isDarkMode ? .dark : .light)
    }

    private func loadUserData() {
        self.userName = "Peter Johnson"
        self.avatarImage = UIImage(named: "placeholder")
    }
    
    private func signOut() {
        self.isAuthenticated = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ProjectViewModel())
    }
}
