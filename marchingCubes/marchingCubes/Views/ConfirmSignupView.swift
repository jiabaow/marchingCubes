//
//  ConfirmSignupView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct ConfirmSignupView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @State private var confirmationCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var isConfirmationSuccessful = false
    var email: String
    var password: String
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
                    .background(Color.green)
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
                    .foregroundColor(.blue)
            }
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
        
//        guard !password.isEmpty else {
//            errorMessage = "Make sure password is passed."
//            return
//        }

        do {
            let cognitoManager = try CognitoAuthManager()

            isConfirmationSuccessful = await cognitoManager.confirmSignUp(username: email, confirmationCode: confirmationCode)
            if (isConfirmationSuccessful) {
                errorMessage = nil
                onConfirmationComplete?()
                currentUser = email
                
                
                
                // perform login
//                let authResult = await cognitoManager.login(username: email, password: password) {
//                    result in
//                    switch result {
//                    case .success:
//                        isAuthenticated = true
//                    case .failure(let error):
//                        if error is AWSCognitoIdentityProvider.UserNotConfirmedException {
//                            print("user not confirmed")
//                        }
//                    }
//                }
//                
//                if (isAuthenticated) {
//                    let accessKeySecretKeySession = await cognitoManager.getCredentials(authResult: authResult?.authenticationResult)!
//                    setenv("AWS_ACCESS_KEY_ID",accessKeySecretKeySession[0],1)
//                    setenv("AWS_SECRET_ACCESS_KEY",accessKeySecretKeySession[1],1)
//                    setenv("AWS_SESSION_TOKEN",accessKeySecretKeySession[2],1)
//                    errorMessage = nil
//                    
//                    let authRes = authResult?.authenticationResult
//                    let dynamoManager = try await DynamoDBManager()
//                    await dynamoManager.createTable()
//                    if let idToken = authRes?.idToken {
//                        try await dynamoManager.insertUserModel(userModel: UserModel(
//                            id: idToken, email: email, username: Randoms.randomFakeName(), profile_image: fetchSVGBase64Async()!, projects: [], favorites: [], created_timestamp: Int(Date().timeIntervalSince1970)
//                        ))
//                    }
//                }
                isAuthenticated = true
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
