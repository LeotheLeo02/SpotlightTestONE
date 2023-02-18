//
//  Login.swift
//  Spotlight
//
//  Created by Nathanael Suarez on 2/18/23.
//

import SwiftUI

import AuthenticationServices
import FirebaseAuth

struct Login: View {
    @StateObject var loginData = LoginViewModel()
    
    var body: some View {
        SignInWithAppleButton { (request) in
            loginData.handleSignInWithAppleRequest(request)
        } onCompletion: { (result) in
            loginData.handleSignInWithAppleCompletion(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 55)
        .cornerRadius(8)

        if Auth.auth().currentUser?.email == "nate.suarez@icloud.com" {
            Text(Auth.auth().currentUser?.email ?? .init())
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
