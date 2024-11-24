//
//  ConfirmSignupView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/16/24.
//

import SwiftUI

struct ConfirmSignupView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @State private var confirmationCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var isConfirmationSuccessful = false
    var username: String
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

        do {
            try await CognitoAuthManager().confirmSignUp(username: username, confirmationCode: confirmationCode)
            isConfirmationSuccessful = true
            errorMessage = nil
            onConfirmationComplete?()
            isAuthenticated = true
            currentUser = username
        } catch {
            print("Confirmation failed: \(error)")
            errorMessage = "Failed to confirm signup. Please check your code and try again."
        }
    }

    func resendConfirmationCode() {
        Task {
            do {
                try await CognitoAuthManager().resendConfirmationCode(username: username)
                errorMessage = nil
                print("Confirmation code resent successfully.")
            } catch {
                print("Failed to resend code: \(error)")
                errorMessage = "Failed to resend the confirmation code. Try again later."
            }
        }
    }
}
