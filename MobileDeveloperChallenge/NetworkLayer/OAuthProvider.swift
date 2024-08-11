//
//  OAuthProvider.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 11/08/2024.
//

import Foundation
import OAuthSwift

class OAuthProvider {
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "YOUR_CLIENT_ID",
        consumerSecret: "YOUR_CLIENT_SECRET",
        authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
        accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
        responseType:   "code"
    )
    
    func auth(){
        oauthswift.authorize(
            withCallbackURL: "yourApp://oauth-callback/google",
            scope: "https://www.googleapis.com/auth/userinfo.profile", state:"GOOGLE") { result in
            switch result {
            case .success(let (credential, response, parameters)):
                print("Access Token: \(credential.oauthToken)")
                // Use the access token to fetch user data
                self.fetchUserData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchUserData(){
        oauthswift.client.get("https://www.googleapis.com/oauth2/v1/userinfo?alt=json") { result in
            switch result {
            case .success(let response):
                let json = try? JSONSerialization.jsonObject(with: response.data, options: [])
                print("User Info: \(String(describing: json))")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


