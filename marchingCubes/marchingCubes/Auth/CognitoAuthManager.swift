//
//  CognitoAuthManager.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/6/24.
//
import Foundation
import AWSCognitoIdentityProvider

class CognitoAuthManager {
    let client: CognitoIdentityProviderClient

    init() throws {
        // Initialize the Cognito client with your region
        self.client = try CognitoIdentityProviderClient(region: "us-east-2") // Replace with your region
    }
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) async {
        
        // Create a sign-up request
        do {
            let authParameters: [String:String] = [
                "USERNAME": username,
                "PASSWORD": password
            ]
            
            let request = InitiateAuthInput(
                authFlow: .userPasswordAuth,
                authParameters: authParameters,
                clientId: "91t5sp3jgildqv5n4e5c4ncd6"
            )
            
            try await self.client.initiateAuth(input: request)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }

    func signUp(username: String, password: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) async {
        let signUpInput = SignUpInput(
            clientId: "91t5sp3jgildqv5n4e5c4ncd6",
            password: password,
            userAttributes: [
                CognitoIdentityProviderClientTypes.AttributeType.init(name: "email", value: email)
            ],
            username: username
        )
        
        // Create a sign-up request
        do {
            _ = try await self.client.signUp(input: signUpInput)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
        
    }
    
    func confirmSignUp(username: String, confirmationCode: String) async {
        let confirmSignUpInput = ConfirmSignUpInput(
            clientId: "91t5sp3jgildqv5n4e5c4ncd6",
            confirmationCode: confirmationCode,
            username: username
        )
        
        do {
            try await self.client.confirmSignUp(input: confirmSignUpInput)
        } catch {
            print(error)
        }
    }
    
    func resendConfirmationCode(username: String) async {
        do {
            let resend = ResendConfirmationCodeInput(clientId: "91t5sp3jgildqv5n4e5c4ncd6", username: username)
            try await self.client.resendConfirmationCode(input: resend)
        } catch {
            print(error)
        }
    }
}
