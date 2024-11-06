//
//  AuthView.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/6/24.
//
import SwiftUI

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
    }
}

struct SignUpView: View {
    @Binding var isLoginView: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                // Implement sign-up logic here
                print("Sign up with username: \(username) and email: \(email)")
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
    }
}

struct AuthSwitcherView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSwitcherView()
    }
}
