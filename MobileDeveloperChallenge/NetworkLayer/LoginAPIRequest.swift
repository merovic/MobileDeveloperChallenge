//
//  LoginAPIRequest.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 11/08/2024.
//

import Foundation
import UIKit

// MARK: - LoginAPIRequest
struct LoginAPIRequest: Codable {
    let phone, password: String
    let platform, ipAddress: String
    let osVersion: String
    let mobileToken: String
    
    init(phone: String, password:String, mobileToken: String){
        self.phone = phone
        self.password = password
        self.platform = "ios"
        self.ipAddress = "192.168.1.1"
        self.osVersion = "iOS " + UIDevice.current.systemVersion
        self.mobileToken = mobileToken
    }

    enum CodingKeys: String, CodingKey {
        case phone = "username"
        case password, platform
        case ipAddress = "ip_address"
        case osVersion = "os_version"
        case mobileToken = "firebase_token"
    }
}


