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
    @State private var isConfirmSignupView: Bool = false
    @State private var pendingName: String = ""
    @State private var pendingUsername: String = ""
    @State private var pendingPassword: String = ""

    var body: some View {
        VStack {
            if isLoginView {
                LoginView(isLoginView: $isLoginView, onUnconfirmedAccount: { username, password in
                    pendingName = Randoms.randomFakeName()
                    pendingUsername = username
                    pendingPassword = password
                    isConfirmSignupView = true
                })
            } else if isConfirmSignupView {
                ConfirmSignupView(name: $pendingName, email: $pendingUsername, password: $pendingPassword) {
                    isConfirmSignupView = false
                    isLoginView = true
                }
            } else {
                SignUpView(isLoginView: $isLoginView, onSignUpSuccess: {
                    isConfirmSignupView = true
                })
            }
        }
    }
}

struct AuthSwitcherView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSwitcherView()
    }
}
