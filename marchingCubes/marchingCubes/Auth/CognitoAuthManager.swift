//
//  CognitoAuthManager.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/6/24.
//
import Foundation
import AWSCognitoIdentityProvider
import AWSCognitoIdentity

class CognitoAuthManager {
    let client: CognitoIdentityProviderClient
    private let region = "us-east-2"
    private let identityPoolId = "us-east-2:f108dcc6-6b69-4b94-8f90-9fa7d1d317da"
    private let userPoolId = "us-east-2_dqxnTyaNK"
    private let clientId = "91t5sp3jgildqv5n4e5c4ncd6"
    private let accountId = "135808916851"
    
    init() throws {
        self.client = try CognitoIdentityProviderClient(region: region) // Replace with your region
    }
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) async -> InitiateAuthOutput? {
        var response: InitiateAuthOutput? = nil
        
        do {
            let authParameters: [String:String] = [
                "USERNAME": username,
                "PASSWORD": password
            ]
            
            let request = InitiateAuthInput(
                authFlow: .userPasswordAuth,
                authParameters: authParameters,
                clientId: clientId
            )
            
            response = try await self.client.initiateAuth(input: request)
            
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
        
        return response
    }
    
    func getCredentials(authResult: CognitoIdentityProviderClientTypes.AuthenticationResultType?) async -> [String]? {
        guard let _ = authResult!.accessToken else {
            print("access token not found")
            return nil
        }
        guard let idToken = authResult!.idToken else {
            print("id token not found")
            return nil
        }
        
        do {
            let cognitoIdentityClient = try CognitoIdentityClient(region: "us-east-2")
            let getIdInput = GetIdInput(
                accountId: accountId,
                identityPoolId: identityPoolId,
                logins: ["cognito-idp.\(region).amazonaws.com/\(userPoolId)": idToken]
            )
            
            let getIdResponse = try await cognitoIdentityClient.getId(input: getIdInput)
            guard let identityId = getIdResponse.identityId else {
                throw NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Identity ID not found"])
            }
            
            let getCredentialsInput = GetCredentialsForIdentityInput(
                identityId: identityId,
                logins: ["cognito-idp.\(region).amazonaws.com/\(userPoolId)": idToken]
            )
            
            let credentialsResponse = try await cognitoIdentityClient.getCredentialsForIdentity(input: getCredentialsInput)
            guard let credentials = credentialsResponse.credentials else {
                throw NSError(domain: "AuthManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "AWS Credentials not found"])
            }
            
            return [credentials.accessKeyId!, credentials.secretKey!, credentials.sessionToken!]
        } catch (let error) {
            print(error)
        }
        
        return nil
    }

    func signUp(username: String, password: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) async -> SignUpOutput? {
        let signUpInput = SignUpInput(
            clientId: clientId,
            password: password,
            userAttributes: [
                CognitoIdentityProviderClientTypes.AttributeType.init(name: "email", value: email)
            ],
            username: username
        )
        
        var response: SignUpOutput? = nil
        
        do {
            response = try await self.client.signUp(input: signUpInput)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
        
        return response
    }
    
    func confirmSignUp(username: String, confirmationCode: String) async -> Bool {
        let confirmSignUpInput = ConfirmSignUpInput(
            clientId: clientId,
            confirmationCode: confirmationCode,
            username: username
        )
        
        do {
            _ = try await self.client.confirmSignUp(input: confirmSignUpInput)
        } catch {
            print(error)
            return false
        }
        
        return true
    }
    
    func resendConfirmationCode(username: String) async {
        do {
            let resend = ResendConfirmationCodeInput(clientId: clientId, username: username)
            _ = try await self.client.resendConfirmationCode(input: resend)
        } catch {
            print(error)
        }
    }
}
