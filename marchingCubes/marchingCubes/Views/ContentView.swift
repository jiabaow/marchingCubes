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
    @AppStorage("lastActiveTime") private var lastActiveTime: Date = Date()
    
    // Define the timeout duration (e.g., 7 days)
    private let timeoutInterval: TimeInterval = 7 * 3600 * 24

    var body: some View {
        Group {
            if isAuthenticated {
                // Show the main content view if authenticated
                MainTabView()
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
    var body: some View {
        TabView {
            Dashboard()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            UploadView()
                .tabItem {
                    Label("Upload", systemImage: "arrow.up")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            MarchingCubesView()
                .tabItem {
                    Label("Test", systemImage: "square.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
