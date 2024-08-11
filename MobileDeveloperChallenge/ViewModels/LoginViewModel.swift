//
//  LoginViewModel.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 10/08/2024.
//

import Foundation
import FirebaseFirestore
import Combine
import LocalAuthentication

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    
    private var db = Firestore.firestore()
    
    func login() {
        let userCollection = db.collection("users")
        
        userCollection.whereField("email", isEqualTo: AES256Cipher.encrypt(email) ?? "").getDocuments { [weak self] querySnapshot, error in
            if let error = error {
                self?.errorMessage = "Error fetching user: \(error.localizedDescription)"
                return
            }
            
            guard let documents = querySnapshot?.documents, documents.count == 1 else {
                self?.errorMessage = "User not found"
                return
            }
            
            let userData = documents.first?.data()
            guard let storedPassword = userData?["password"] as? String else {
                self?.errorMessage = "Error retrieving user data"
                return
            }
            
            if storedPassword == AES256Cipher.encrypt(self?.password ?? "") {
                self?.isLoggedIn = true
                self?.errorMessage = nil
            } else {
                self?.errorMessage = "Incorrect password"
            }
        }
    }
    
    func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate to proceed."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self.isLoggedIn = true
                            self.errorMessage = nil
                        } else {
                            self.errorMessage = authenticationError?.localizedDescription ?? "Failed to authenticate"
                        }
                    }
                }
            } else {
                errorMessage = error?.localizedDescription ?? "Biometrics not available"
            }
        }
}
