//
//  ContentView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI

struct ContentView: View {
    // Use @AppStorage to persist authentication state across app launches
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @AppStorage("lastActiveTime") private var lastActiveTime: Date = Date()
    @StateObject private var userViewModel = UserViewModel() // Initialized once
    
    // Define the timeout duration (e.g., 7 days)
    private let timeoutInterval: TimeInterval = 7 * 3600 * 24
    
    var body: some View {
        Group {
            if isAuthenticated {
                // Show the main content view if authenticated
                MainTabView(userViewModel: userViewModel)
            } else {
                // Show the sign-in view if not authenticated
                AuthSwitcherView()
            }
        }
    }
    
    
    // Start a timer to check for inactivity
    private func startInactivityTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            checkInactivity()
        }
    }
    
    // Check if the user should be logged out due to inactivity
    private func checkInactivity() {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastActiveTime) > timeoutInterval {
            isAuthenticated = false
        }
    }
}

struct MainTabView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @State private var hasTaskRun = false
    @ObservedObject var userViewModel: UserViewModel // Use @ObservedObject instead
    
    var body: some View {
        TabView {
            Dashboard()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }.task{
                    if !hasTaskRun {
                        hasTaskRun = true
                        do {
                            try await fetchUserDataIfAuthenticated(currentUser: currentUser, userViewModel: userViewModel)
                        } catch (let error) {
                            print("\(error)")
                            currentUser = ""
                            isAuthenticated = false
                        }
                    }
                }
            
            //            AddModelView()
            //                .tabItem {
            //                    Label("Upload", systemImage: "arrow.up")
            //                }
            ProfileView(userViewModel: userViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }.task {
                    do {
                        try await fetchUserDataIfAuthenticated(currentUser: currentUser, userViewModel: userViewModel)
                    } catch (let error) {
                        print("\(error)")
                        currentUser = ""
                        isAuthenticated = false
                    }
                }
            
            //            MarchingCubesView()
            //                .tabItem {
            //                    Label("Test", systemImage: "square.fill")
            //                }
        }
    }
    
    // Fetch user data if authenticated
    private func fetchUserDataIfAuthenticated(currentUser: String = "", userViewModel: UserViewModel) async throws {
        guard !currentUser.isEmpty else {
            throw NSError(domain: "MainTabView", code: -1, userInfo: ["fetchUserDataIfAuthenticated": "User unauthenticated."])
        }
        do {
            try await userViewModel.fetchUserData(idToken: currentUser)
        } catch (let error) {
            print("\(error)")
            throw NSError(domain: "MainTabView", code: -1, userInfo: ["fetchUserDataIfAuthenticated": "\(error)"])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ProjectViewModel())
    }
}
