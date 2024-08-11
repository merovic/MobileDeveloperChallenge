//
//  ItemModel.swift
//  ToDoList
//
//  Created by Denis DRAGAN on 29.10.2023.
//

import Foundation

struct ItemModel: Identifiable, Codable {
    let id: String
    let title: String
    let isCompleted: Bool
    let timestamp: Date

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool, timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.timestamp = timestamp
    }
    
    func updateCompletion() -> ItemModel {
        return ItemModel(id: id, title: title, isCompleted: !isCompleted, timestamp: Date())
    }
}
