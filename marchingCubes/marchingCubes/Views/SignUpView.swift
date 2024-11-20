//
//  SignUpView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct SignUpView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @Binding var isLoginView: Bool
    var onSignUpSuccess: (() -> Void)? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var showConfirmSignupView = false
    @State private var pendingUsername: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if let emailError = emailError {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if let passwordError = passwordError {
                Text(passwordError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button(action: {
                validateInputs()
                Task {
                    await performSignUp()
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: {
                isLoginView.toggle()
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)

            Spacer()

            Button(action: continueAsGuest) {
                Text("Continue as Guest")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .fullScreenCover(isPresented: $showConfirmSignupView) {
            ConfirmSignupView(username: email.lowercased()) {
                showConfirmSignupView = false
            }
        }
    }
    
    func continueAsGuest() {
        isAuthenticated = true
    }

    func validateInputs() {
        emailError = email.isEmpty ? "Email is required." : nil
        passwordError = password.isEmpty ? "Password is required." : nil

        if let emailError = emailError, !email.isEmpty {
            if !email.contains("@") {
                self.emailError = "Invalid email format."
            }
        }

        if let passwordError = passwordError, !password.isEmpty {
            if password.count < 6 {
                self.passwordError = "Password must be at least 6 characters."
            }
        }
    }

    func performSignUp() async {
        // Ensure inputs are valid before attempting sign-up
        guard emailError == nil, passwordError == nil else {
            return
        }

        do {
            // Perform the signup operation
            try await CognitoAuthManager().signUp(username: email.lowercased(), password: password, email: email.lowercased()) { result in
                switch result {
                case .success:
                    print("Sign-up successful!")
                    pendingUsername = email.lowercased()
                    showConfirmSignupView = true
                case .failure(let error):
                    print("Sign-up failed with error: \(error)")
                    handleSignUpError(error)
                }
            }
        } catch {
            print("Unexpected error: \(error)")
            handleSignUpError(error)
        }
    }

    func handleSignUpError(_ error: Error) {
        if let cognitoError = error as? AWSCognitoIdentityProvider.UsernameExistsException {
            emailError = "An account with this email already exists."
        } else if let cognitoError = error as?
                    AWSCognitoIdentityProvider.InvalidPasswordException {
            passwordError = "Invalid password format."
        } else if let cognitoError = error as?
                    AWSCognitoIdentityProvider.InvalidEmailRoleAccessPolicyException {
            emailError = "Invalid email address."
        } else {
            print("Unknown error: \(error)")
        }
    }
}
