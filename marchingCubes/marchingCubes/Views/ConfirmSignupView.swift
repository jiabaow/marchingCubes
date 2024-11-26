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
    @State private var confirmationCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var isConfirmationSuccessful = false
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
                        isAuthenticated = true
                    case .failure(let error):
                        if error is AWSCognitoIdentityProvider.UserNotConfirmedException {
                            print("user not confirmed")
                        }
                    }
                }
                
                if (isAuthenticated) {
                    let accessKeySecretKeySession = await cognitoManager.getCredentials(authResult: authResult?.authenticationResult)!
                    setenv("AWS_ACCESS_KEY_ID",accessKeySecretKeySession[0],1)
                    setenv("AWS_SECRET_ACCESS_KEY",accessKeySecretKeySession[1],1)
                    setenv("AWS_SESSION_TOKEN",accessKeySecretKeySession[2],1)
                    errorMessage = nil
                    
                    let authRes = authResult?.authenticationResult
                    let dynamoManager = try await DynamoDBManager()
                    await dynamoManager.createTable()
                    if let idToken = authRes?.idToken {
                        // Parse the idToken to extract `sub`
                        if let subValue = extractSubFromIDToken(idToken) {
                            print("Extracted sub: \(subValue)")
                            
                            // Use the `sub` value as the ID in the UserModel
                            try await dynamoManager.insertUserModel(userModel: UserModel(
                                id: subValue, // Use `sub` as the ID
                                email: email,
                                username: Randoms.randomFakeName(),
                                profile_image: fetchSVGBase64Async()!,
                                projects: [],
                                favorites: [],
                                created_timestamp: Int(Date().timeIntervalSince1970)
                            ))
                        } else {
                            print("Failed to extract sub from idToken")
                        }
                    }                }
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

func extractSubFromIDToken(_ idToken: String) -> String? {
    // Split the JWT into its three parts
    let segments = idToken.split(separator: ".")
    guard segments.count == 3 else {
        print("Invalid JWT format")
        return nil
    }
    
    // Get the payload segment (second part of the JWT)
    let payloadSegment = segments[1]
    
    // Add padding if necessary
    var base64String = String(payloadSegment)
        .replacingOccurrences(of: "-", with: "+") // URL-safe to standard Base64
        .replacingOccurrences(of: "_", with: "/") // URL-safe to standard Base64
    while base64String.count % 4 != 0 { // Add padding if necessary
        base64String.append("=")
    }
    
    // Decode the Base64 payload
    guard let payloadData = Data(base64Encoded: base64String) else {
        print("Failed to decode Base64")
        return nil
    }
    
    // Convert to JSON and extract the `sub` field
    do {
        if let payloadJson = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
           let subValue = payloadJson["sub"] as? String {
            return subValue
        } else {
            print("Failed to parse JSON or find 'sub' key")
            return nil
        }
    } catch {
        print("Failed to parse JSON: \(error)")
        return nil
    }
}
