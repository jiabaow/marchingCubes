//
//  ProfileView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @State private var avatarImage: UIImage? = nil
    
    var body: some View {
        VStack {
            Text("Profile Placeholder")
                .font(.largeTitle)
                .padding()
            
            // Circular Avatar
            if let avatarImage = avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding()
            } else {
                // Placeholder while loading
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding()
            }
            
            // Sign-out button
            Button(action: {
                // Add your sign-out logic here
                signOut()
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
        }.onAppear {
            fetchSVGImage { image in
                DispatchQueue.main.async {
                    self.avatarImage = image
                }
            }
        }
    }
    
    // Function to handle sign-out logic
    func signOut() {
        // Implement your sign-out logic here
        print("User signed out")
        isAuthenticated = false
    }
}


struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
