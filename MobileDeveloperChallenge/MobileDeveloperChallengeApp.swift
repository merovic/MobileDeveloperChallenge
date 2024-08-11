//
//  MobileDeveloperChallengeApp.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 10/08/2024.
//

import SwiftUI
import Firebase
import OAuthSwift

@main
struct MobileDeveloperChallengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
        
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        return true
    }
}
