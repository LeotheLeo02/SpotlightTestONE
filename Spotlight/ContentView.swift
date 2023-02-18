//
//  ContentView.swift
//  Spotlight
//
//  Created by Nathanael Suarez on 2/15/23.
//

import SwiftUI
import FirebaseDatabase
import AVFoundation
import AuthenticationServices
import FirebaseAuth


struct ContentView: View {
    @StateObject var loginData = LoginViewModel()
    let ref = Database.database().reference()
    @State var string = ""
    var body: some View {
        VStack {
            if Auth.auth().currentUser?.email == "nate.suarez@icloud.com" {
                TouchesHandler(didBeginTouch: {
                    self.ref.child("message").setValue("On")
                },didEndTouch: {
                    self.ref.child("message").setValue("Off")
                })
            }
            Text(string)
            SignInWithAppleButton { (request) in
                loginData.handleSignInWithAppleRequest(request)
            } onCompletion: { (result) in
                loginData.handleSignInWithAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 55)
            .cornerRadius(8)
        }.onAppear(){
            ref.child("message").observe(.value) { snapshot in
                if snapshot.value as? String ?? "Failed" == "On" {
                    toggleTorch(on: true)
                    string = "On"
                }else {
                    toggleTorch(on: false)
                    string = "Off"
                }
            }
        }
        .padding()
    }
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return}
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on{
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
            } catch {
                print("Error using torch")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
