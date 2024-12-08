//
//  LoginView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI
import AWSCognitoIdentityProvider

import SwiftUI
import AWSCognitoIdentityProvider

struct LoginView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @AppStorage("userToken") private var userToken = ""
    @Binding var isLoginView: Bool
    @State private var name: String = Randoms.randomFakeName()
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String? = nil
    var onUnconfirmedAccount: ((String, String) -> Void)? = nil
    @State private var showConfirmSignupView = false

    var body: some View {
        VStack(spacing: 20) {
            
            HStack() {
                // Title
                Text("Login")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primaryBlue)
                    .padding(.top, 20)
                    .padding(.leading, 15)
                Spacer()
                Image(systemName: "cube.fill") // Replace with your logo
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primaryBlue)
                    .padding(.trailing, 15)

            }

            // Email Field
            TextField("Email", text: $username)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .autocapitalization(.none)

            // Password Field with Visibility Toggle
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                } else {
                    SecureField("Password", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                }
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            // Forgot Password Link
            Button(action: {
                // Handle forgot password logic here
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
            }

            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            // Login Button
            Button(action: {
                Task {
                    await performLogin()
                }
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Login Prompt
            HStack {
                Button(action: {
                    isLoginView.toggle()
                }) {
                    Text("Don't have an Account?")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    isLoginView.toggle()
                }) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showConfirmSignupView) {
            ConfirmSignupView(name: $name, email: $username, password: $password) {
                showConfirmSignupView = false
            }
        }
    }

    func performLogin() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password."
            return
        }
        
        var isAuthed = false

        do {
            let cognitoManager = try CognitoAuthManager()

            let authResult = await cognitoManager.login(username: username, password: password) {
                result in
                switch result {
                    case .success:
                        isAuthed = true
                    case .failure(let error):
                        if error is AWSCognitoIdentityProvider.UserNotConfirmedException {
                            print("User not confirmed")
                            print("password before confirmed: \(password)")
                            showConfirmSignupView = true
                            print("password after confirmed: \(password)")
                        } else if error is AWSCognitoIdentityProvider.NotAuthorizedException {
                            print("Incorrect username or password")
                            errorMessage = "Incorrect username or password"
                        }
                }
            }
            if (isAuthed) {
                let accessKeySecretKeySession = await cognitoManager.getCredentials(authResult: authResult?.authenticationResult)!
                setenv("AWS_ACCESS_KEY_ID", accessKeySecretKeySession[0], 1)
                setenv("AWS_SECRET_ACCESS_KEY", accessKeySecretKeySession[1], 1)
                setenv("AWS_SESSION_TOKEN", accessKeySecretKeySession[2], 1)
                errorMessage = nil
                
                let authRes = authResult?.authenticationResult
                if let idToken = authRes?.idToken {
                    // Parse the idToken to extract `sub`
                    if let subValue = extractSubFromIDToken(idToken) {
                        print("Extracted sub: \(subValue)")
                        currentUser = "\(subValue):\(username)"
                        userToken = subValue
                        var retryCount = 0
                        let maxRetries = 5
                        var delay: UInt64 = 1 // Start with a 1-second delay
                        var userModEx: UserModel? = nil
                        
                        while retryCount < maxRetries {
                            let dynamoManager = try await DynamoDBManager()
                            userModEx = await dynamoManager.getUserModel(idToken: currentUser) // Assign result to userModEx
                            if userModEx != nil {
                                print("User exists in DynamoDB.")
                                isAuthenticated = isAuthed
                                return
                            } else {
                                    // Use the `sub` value as the ID in the UserModel
                                    _ = await dynamoManager.insertUserModel(userModel: UserModel(
                                    id: subValue, // Use `sub` as the ID
                                    email: username,
                                    username: name,
                                    profile_image: fetchSVGBase64Async()!,
                                    projects: [],
                                    favorites: [],
                                    created_timestamp: Int(Date().timeIntervalSince1970)
                                ))

                                if retryCount == maxRetries - 1 {
                                    print("Maximum retries reached. User creation failed.")
                                    throw NSError(domain: "DynamoDB", code: 1, userInfo: ["message": "Failed to verify or create user in DynamoDB."])
                                }
                                print("User not found. Retrying in \(delay) seconds...")
                                try await Task.sleep(nanoseconds: delay * 1_000_000_000)
                                delay *= 2 // Exponential backoff
                                retryCount += 1
                            }
                        }
                        
                        
                    } else {
                        print("Failed to extract sub from idToken")
                    }
                } // idToken

                
            }
        } catch let error as AWSCognitoIdentityProvider.UserNotConfirmedException {
            errorMessage = "Account not confirmed. Please confirm your account."
            onUnconfirmedAccount?(username, password)
        } catch let error as AWSCognitoIdentityProvider.NotAuthorizedException {
            errorMessage = "Incorrect username or password."
        } catch {
            print("Login failed: \(error)")
            errorMessage = "Login failed. Check your credentials and try again."
        }
    }
}
