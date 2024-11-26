//
//  SignUpView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//
import ClientRuntime
import SwiftUI
import AWSCognitoIdentityProvider
import AWSCognitoIdentity

struct SignUpView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @Binding var isLoginView: Bool
    var onSignUpSuccess: (() -> Void)? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var showConfirmSignupView = false
    @State private var pendingUsername: String = ""
    @State private var pendingPassword: String = ""
    @State private var name: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome to")
                            .font(.title2)
                            .foregroundColor(Color(.systemGray))

                        Text("Marching Cubes!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryBlue)
                            .padding(.bottom, 20)
                    }

                    Spacer()

                    Image(systemName: "cube.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(.horizontal)

            Group {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                if let emailError = emailError {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                if let passwordError = passwordError {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                HStack {
                    if isConfirmPasswordVisible {
                        TextField("Confirm Password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                    Button(action: {
                        isConfirmPasswordVisible.toggle()
                    }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            HStack {
                Button(action: {
                    isLoginView.toggle()
                }) {
                    Text("Have an Account?")
                        .foregroundColor(.gray)
                }

                Button(action: {
                    isLoginView.toggle()
                }) {
                    Text("Login")
                        .fontWeight(.bold)
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(.top, 10)

            Button(action: {
                validateInputs()
                Task {
                    await performSignUp()
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .fullScreenCover(isPresented: $showConfirmSignupView) {
            ConfirmSignupView(email: $pendingUsername, password: $pendingPassword) { // Pass password directly
                showConfirmSignupView = false
            }
        }
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

        if password != confirmPassword {
            self.passwordError = "Passwords do not match."
        }
    }

    func performSignUp() async {
        guard emailError == nil, passwordError == nil else {
            return
        }

        do {
            let cognitoManager = try CognitoAuthManager()
            let authResult = await cognitoManager.signUp(username: email.lowercased(), password: password, email: email.lowercased()) { result in
                switch result {
                case .success:
                    print("Sign-up successful!")
                    pendingUsername = email.lowercased()
                    pendingPassword = password
                    print("CHARLES2---")
                    print(pendingUsername)
                    print(pendingPassword)
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
        } else if let cognitoError = error as? AWSCognitoIdentityProvider.InvalidPasswordException {
            passwordError = "Invalid password format."
        } else if let cognitoError = error as? AWSCognitoIdentityProvider.InvalidEmailRoleAccessPolicyException {
            emailError = "Invalid email address."
        } else {
            print("Unknown error: \(error)")
        }
    }
}
