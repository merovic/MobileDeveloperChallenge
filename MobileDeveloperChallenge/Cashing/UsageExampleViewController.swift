//
//  UsageExampleViewController.swift
//  ToDoList
//
//  Created by PaySky106 on 06/08/2024.
//

import UIKit

class UsageExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://example.com/data.json")!
        fetchData(from: url)
    }
    
    func fetchData(from url: URL) {
        DataCacheManager.shared.fetchData(from: url) { [weak self] data in
            guard let data = data else {
                // Handle the error
                return
            }
            // Use the fetched data
            self?.handleFetchedData(data)
        }
    }
    
    func handleFetchedData(_ data: Data) {
        // Process and display the data
    }
}
