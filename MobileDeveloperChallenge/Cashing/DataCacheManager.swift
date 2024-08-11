//
//  DataCacheManager.swift
//  ToDoList
//
//  Created by PaySky106 on 06/08/2024.
//

import Foundation
import Alamofire
import Network
import UIKit

class DataCacheManager {
    static let shared = DataCacheManager()
    private let memoryCache = NSCache<NSString, NSData>()
    private let diskCacheURL: URL
    private let networkMonitor = NetworkMonitor.shared
    private var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    private init() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("DiskCache")
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    func cacheData(_ data: Data, forKey key: String) {
        let nsKey = NSString(string: key)
        
        switch UserPreferences.preferredCacheType {
        case .memory:
            memoryCache.setObject(data as NSData, forKey: nsKey)
        case .disk:
            let fileURL = diskCacheURL.appendingPathComponent(key)
            try? data.write(to: fileURL)
        case .hybrid:
            memoryCache.setObject(data as NSData, forKey: nsKey)
            let fileURL = diskCacheURL.appendingPathComponent(key)
            try? data.write(to: fileURL)
        }
    }
    
    func fetchData(forKey key: String) -> Data? {
        let nsKey = NSString(string: key)
        
        switch UserPreferences.preferredCacheType {
        case .memory:
            return memoryCache.object(forKey: nsKey) as Data?
        case .disk:
            let fileURL = diskCacheURL.appendingPathComponent(key)
            return try? Data(contentsOf: fileURL)
        case .hybrid:
            if let memoryData = memoryCache.object(forKey: nsKey) {
                return memoryData as Data
            }
            let fileURL = diskCacheURL.appendingPathComponent(key)
            if let diskData = try? Data(contentsOf: fileURL) {
                memoryCache.setObject(diskData as NSData, forKey: nsKey)
                return diskData
            }
            return nil
        }
    }
    
    func fetchData(from url: URL, completion: @escaping (Data?) -> Void) {
        let key = url.absoluteString
        
        // Check cache
        if let cachedData = fetchData(forKey: key) {
            completion(cachedData)
            return
        }
        
        // Check network conditions and device resources
        if !networkMonitor.isConnected || batteryLevel < 0.2 {
            completion(nil)
            return
        }
        
        // Fetch from network using Alamofire
        AF.request(url).responseData { [weak self] response in
            guard let data = response.data, response.error == nil else {
                completion(nil)
                return
            }
            self?.cacheData(data, forKey: key)
            completion(data)
        }
    }
}
