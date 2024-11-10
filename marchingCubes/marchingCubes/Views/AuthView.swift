//
//  AuthView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/6/24.
//
import SwiftUI
import AWSCognitoIdentityProvider

struct AuthSwitcherView: View {
    @State private var isLoginView: Bool = true

    var body: some View {
        VStack {
            if isLoginView {
                LoginView(isLoginView: $isLoginView)
            } else {
                SignUpView(isLoginView: $isLoginView)
            }
        }
    }
}

struct LoginView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @Binding var isLoginView: Bool
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                // Implement login logic here
                print("Login with username: \(username)")
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
    }

    func continueAsGuest() {
        // Implement continue as guest logic here
        print("Continuing as guest.")
        isAuthenticated = true
    }
}

struct SignUpView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @Binding var isLoginView: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var emailError: String? = nil
    @State private var usernameError: String? = nil
    @State private var passwordError: String? = nil

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

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if let usernameError = usernameError {
                Text(usernameError)
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
    }

    func continueAsGuest() {
        // Implement continue as guest logic here
        print("Continuing as guest.")
        isAuthenticated = true
    }
    
    func validateInputs() {
        emailError = email.isEmpty ? "Email is required." : nil
        usernameError = username.isEmpty ? "Username is required." : nil
        passwordError = password.isEmpty ? "Password is required." : nil

        if let emailError = emailError, !email.isEmpty {
            // Add more complex email validation if needed
            if !email.contains("@") {
                self.emailError = "Invalid email format."
            }
        }

        if let passwordError = passwordError, !password.isEmpty {
            // Add more complex password validation if needed
            if password.count < 6 {
                self.passwordError = "Password must be at least 6 characters."
            }
        }
    }
    
    func performSignUp() async {
        // Ensure inputs are valid before attempting sign-up
        guard emailError == nil, usernameError == nil, passwordError == nil else {
            return
        }

        do {
            try await CognitoAuthManager().signUp(username: username, password: password, email: email) { result in
                switch result {
                case .success:
                    print("Sign-up successful!")
                    isAuthenticated = true
                case .failure(let error):
                    print("Sign-up failed with error: \(error)")
                    handleSignUpError(error)
                    // Handle sign-up failure logic here
                }
            }
        } catch {
            print("Unexpected error: \(error)")
            handleSignUpError(error)
            // Handle unexpected error logic here
        }
    }
    
    func handleSignUpError(_ error: Error) {
        if let cognitoError = error as? AWSCognitoIdentityProvider.UsernameExistsException {
            usernameError = "Username already exists."
        } else if let cognitoError = error as?
                    AWSCognitoIdentityProvider.InvalidPasswordException {
            passwordError = "Invalid password."
        } else if let cognitoError = error as?
                    AWSCognitoIdentityProvider.InvalidEmailRoleAccessPolicyException {
            emailError = "Invalid email."
        } else {
            print("Unknown error: ", error)
        }
    }
}

struct AuthSwitcherView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSwitcherView()
    }
}
