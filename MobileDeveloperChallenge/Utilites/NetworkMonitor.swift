//
//  NetworkMonitor.swift
//  ToDoList
//
//  Created by PaySky106 on 06/08/2024.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private(set) var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
