//
//  ConfirmSignupView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct ConfirmSignupView: View {
    @Environment(\.dismiss) private var dismiss // For dismissing the view
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @AppStorage("userToken") private var userToken = ""
    @State private var confirmationCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var isConfirmationSuccessful = false
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    var onConfirmationComplete: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Signup")
                .font(.largeTitle)
                .padding()

            Text("Enter the confirmation code sent to your email to complete the signup process.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Confirmation Code", text: $confirmationCode)
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
                    await confirmSignup()
                }
            }) {
                Text("Confirm Signup")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.primaryBlue))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            if isConfirmationSuccessful {
                Text("Confirmation Successful! You can now log in.")
                    .foregroundColor(.green)
                    .padding(.top)
            }

            Spacer()

            Button(action: resendConfirmationCode) {
                Text("Resend Confirmation Code")
                    .foregroundColor(.primaryBlue)
            }
            
            // "Go Back" Button
            Button(action: {
                dismiss() // Go back to the previous view
            }) {
                Text("Go Back")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    func confirmSignup() async {
        guard !confirmationCode.isEmpty else {
            errorMessage = "Please enter the confirmation code."
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Make sure username/email is passed."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Make sure password is passed."
            return
        }
        
        var isAuthed = false

        do {
            let cognitoManager = try CognitoAuthManager()

            isConfirmationSuccessful = await cognitoManager.confirmSignUp(username: email, confirmationCode: confirmationCode)
            if (isConfirmationSuccessful) {
                errorMessage = nil
//                onConfirmationComplete?()
                currentUser = email
                
                // perform login
                let authResult = await cognitoManager.login(username: email, password: password) {
                    result in
                    switch result {
                    case .success:
                        isAuthed = true
                    case .failure(let error):
                        if error is AWSCognitoIdentityProvider.UserNotConfirmedException {
                            print("user not confirmed")
                        }
                    }
                }
                
                if (isAuthed) {
                    let accessKeySecretKeySession = await cognitoManager.getCredentials(authResult: authResult?.authenticationResult)!
                    setenv("AWS_ACCESS_KEY_ID",accessKeySecretKeySession[0],1)
                    setenv("AWS_SECRET_ACCESS_KEY",accessKeySecretKeySession[1],1)
                    setenv("AWS_SESSION_TOKEN",accessKeySecretKeySession[2],1)
                    errorMessage = nil
                    
                    let authRes = authResult?.authenticationResult
                    if let idToken = authRes?.idToken {
                        // Parse the idToken to extract `sub`
                        if let subValue = extractSubFromIDToken(idToken) {
                            print("Extracted sub: \(subValue)")
                            currentUser = "\(subValue):\(email)"
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
                                    _ = await dynamoManager.insertUserModel(userModel: UserModel(
                                        id: subValue, // Use `sub` as the ID
                                        email: email,
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
                } // isAuthenticated
            }
        } catch {
            print("Confirmation failed: \(error)")
            errorMessage = "Failed to confirm signup. Please check your code and try again."
        }
    }

    func resendConfirmationCode() {
        Task {
            do {
                try await CognitoAuthManager().resendConfirmationCode(username: email)
                errorMessage = nil
                print("Confirmation code resent successfully.")
            } catch {
                print("Failed to resend code: \(error)")
                errorMessage = "Failed to resend the confirmation code. Try again later."
            }
        }
    }
}
