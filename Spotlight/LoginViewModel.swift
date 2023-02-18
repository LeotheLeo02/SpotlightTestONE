//
//  LoginViewModel.swift
//  Spotlight
//
//  Created by Nathanael Suarez on 2/18/23.
//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

class LoginViewModel: ObservableObject {
    
    @Published var currentNounce: String?
    
    @Published var errorMessage = ""
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }catch {
            print(error)
        }
    }
    func handleSignInWithAppleRequest (_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [. fullName,.email]
        let nonce = randomNonceString()
        currentNounce = nonce
        request.nonce = sha256(nonce)
    }
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            errorMessage = failure.localizedDescription
        }
        else if case .success(let success) = result {
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNounce else {
                    fatalError("Invalid State: a login callback was recieved, but no login request was sent")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print ("Unable to fetch identity token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print ("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                                rawNonce: nonce)
                
                Task {
                    do {
                        let result  = try await Auth.auth().signIn(with: credential)
                    } catch {
                        print ("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}


func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

    
