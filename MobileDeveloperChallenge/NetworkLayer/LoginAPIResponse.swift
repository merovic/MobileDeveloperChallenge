//
//  LoginAPIResponse.swift
//  Teseppas Loylaty
//
//  Created by Amir Ahmed on 13/07/2022.
//

import Foundation

// MARK: - LoginAPIResponse
struct LoginAPIResponse: Codable {
    let id: Int
    let name, firstName, lastName, email: String
    let phone, countryCode, firebaseToken, apiToken: String
    let isCompany: Bool
    let imagePath, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
        case countryCode = "country_code"
        case firebaseToken = "firebase_token"
        case apiToken = "api_token"
        case isCompany = "is_company"
        case imagePath = "image_path"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension LoginAPIResponse: Equatable {}
