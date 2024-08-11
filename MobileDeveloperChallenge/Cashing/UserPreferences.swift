//
//  UserPreferences.swift
//  ToDoList
//
//  Created by PaySky106 on 06/08/2024.
//

import Foundation

struct UserPreferences {
    static var shouldCacheData: Bool {
        return UserDefaults.standard.bool(forKey: "shouldCacheData")
    }
    
    static var preferredCacheType: CacheType {
        let value = UserDefaults.standard.integer(forKey: "preferredCacheType")
        return CacheType(rawValue: value) ?? .hybrid
    }
    
    enum CacheType: Int {
        case memory, disk, hybrid
    }
}
