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

    func signUp(username: String, password: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) async {
        let signUpInput = SignUpInput(
            clientId: "68g2sfl6kbeacqrekd8s8oq2u2",
            password: password,
            userAttributes: [
                CognitoIdentityProviderClientTypes.AttributeType.init(name: "email", value: email)
            ],
            username: username
        )
        
        // Create a sign-up request
        do {
            let signUpRequest = try await self.client.signUp(input: signUpInput)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
        
        // Call the confirm sign-up API
        // self.client.confirmSignUp(input: <#T##ConfirmSignUpInput#>)
    }
}
