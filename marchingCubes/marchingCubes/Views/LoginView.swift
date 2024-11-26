//
//  LoginView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct LoginView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @Binding var isLoginView: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    var onUnconfirmedAccount: ((String, String) -> Void)? = nil
    @State private var showConfirmSignupView = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button(action: {
                Task {
                    await performLogin()
                }
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: {
                isLoginView.toggle()
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)

//            Spacer()
//
//            Button(action: continueAsGuest) {
//                Text("Continue as Guest")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding(.horizontal)
        }
        .padding()
        .fullScreenCover(isPresented: $showConfirmSignupView) {
            ConfirmSignupView(email: username.lowercased(), password: password) {
                showConfirmSignupView = false
            }
        }
    }

    func continueAsGuest() {
        isAuthenticated = true
    }

    func performLogin() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password."
            return
        }
        

        do {
            let cognitoManager = try CognitoAuthManager()

            let authResult = await cognitoManager.login(username: username, password: password) {
                result in
                switch result {
                    case .success:
                        isAuthenticated = true
                    case .failure(let error):
                        if error is AWSCognitoIdentityProvider.UserNotConfirmedException {
                            print("user not confirmed")
                            showConfirmSignupView = true
                        }
                }
            }
            if (isAuthenticated) {
                let accessKeySecretKeySession = await cognitoManager.getCredentials(authResult: authResult?.authenticationResult)!
                setenv("AWS_ACCESS_KEY_ID",accessKeySecretKeySession[0],1)
                setenv("AWS_SECRET_ACCESS_KEY",accessKeySecretKeySession[1],1)
                setenv("AWS_SESSION_TOKEN",accessKeySecretKeySession[2],1)
                errorMessage = nil
            }
        } catch let error as AWSCognitoIdentityProvider.UserNotConfirmedException {
            // Redirect to ConfirmSignupView
            errorMessage = "Account not confirmed. Please confirm your account."
            onUnconfirmedAccount?(username, password)
        } catch {
            print("Login failed: \(error)")
            errorMessage = "Login failed. Check your credentials and try again."
        }
    }
}
