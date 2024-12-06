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
    @ObservedObject var userViewModel: UserViewModel
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack {
            Spacer()

            // Display different content based on the selected index
            switch selectedIndex {
            case 0:
                Dashboard()
                    .task {
                        if !hasTaskRun {
                            hasTaskRun = true
                            do {
                                try await fetchUserDataIfAuthenticated(currentUser: currentUser, userViewModel: userViewModel)
                            } catch {
                                print("\(error)")
                                currentUser = ""
                                isAuthenticated = false
                            }
                        }
                    }
            case 1:
                ProfileView(userViewModel: userViewModel)
                    .task {
                        do {
                            try await fetchUserDataIfAuthenticated(currentUser: currentUser, userViewModel: userViewModel)
                        } catch {
                            print("\(error)")
                            currentUser = ""
                            isAuthenticated = false
                        }
                    }
            case 2:
                AddModelView()
            default:
                Dashboard()
            }

            ZStack {
                // Custom background shape for Tab Bar
                CustomTabBarShape()
                    .fill(Color.white)
                    .frame(height: 80)
                    .shadow(radius: 5)

                // Custom Tab Bar Buttons
                HStack {
                    // Dashboard Button
                    Button(action: {
                        selectedIndex = 0
                    }) {
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 25))
                                .font(.footnote)
                        }
                        .foregroundColor(selectedIndex == 0 ? Color(hex: "5A60E3") : .gray)
                    }

                    Spacer()

                    // Add Button - Centered on the notch
                    Button(action: {
                        selectedIndex = 2
                    }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                        }
                        .foregroundColor(Color(hex: "5A60E3"))
                        .padding(.bottom, 80) // Adjust padding to align it correctly with the notch
                        .offset(x: -5)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Profile Button
                    Button(action: {
                        selectedIndex = 1
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 25))
                                .font(.footnote)
                        }
                        .foregroundColor(selectedIndex == 1 ? Color(hex: "5A60E3") : .gray)
                    }
                }
                .frame(height: 80)
                .padding(.horizontal, 50) // Adjust horizontal padding to make room for the center button
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // Fetch user data if authenticated
    private func fetchUserDataIfAuthenticated(currentUser: String = "", userViewModel: UserViewModel) async throws {
        guard !currentUser.isEmpty else {
            throw NSError(domain: "MainTabView", code: -1, userInfo: ["fetchUserDataIfAuthenticated": "User unauthenticated."])
        }
        do {
            try await userViewModel.fetchUserData(idToken: currentUser)
        } catch let error {
            print("\(error)")
            throw NSError(domain: "MainTabView", code: -1, userInfo: ["fetchUserDataIfAuthenticated": "\(error)"])
        }
    }
}

struct CustomTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 60.0
        let notchHeight: CGFloat = 60.0

        // Start from the bottom-left corner
        path.move(to: CGPoint(x: 0, y: 0))
        // Draw the line to the start of the notch
        path.addLine(to: CGPoint(x: rect.width / 2 - notchRadius, y: 0))
        // Draw the notch curve
        path.addQuadCurve(
            to: CGPoint(x: rect.width / 2 + notchRadius, y: 0),
            control: CGPoint(x: rect.width / 2, y: notchHeight)
        )
        // Draw the line to the end of the top edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        // Draw the right edge downwards
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        // Draw the bottom edge to the left, making it flush with the tab bar background
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        // Close the path on the left edge
        path.closeSubpath()

        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(userViewModel: UserViewModel())
            .environmentObject(ProjectViewModel())
    }
}
