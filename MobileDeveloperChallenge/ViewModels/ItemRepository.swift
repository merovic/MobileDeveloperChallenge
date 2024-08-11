//
//  ItemRepository.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 11/08/2024.
//

import Foundation
import FirebaseFirestore
import Network


// MARK: - ItemRepository
class ItemRepository {
    private let db = Firestore.firestore()
    private let collectionName = "items"
    
    func addItem(_ item: ItemModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection(collectionName).document(item.id).setData(from: item) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func updateItem(_ item: ItemModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection(collectionName).document(item.id).setData(from: item) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchItems(completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        db.collection(collectionName).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let items = snapshot?.documents.compactMap { document -> ItemModel? in
                    try? document.data(as: ItemModel.self)
                }
                completion(.success(items ?? []))
            }
        }
    }
    
    func updateItemWithConflictResolution(_ item: ItemModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = db.collection(collectionName).document(item.id)
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            if let existingItem = try? document.data(as: ItemModel.self) {
                let resolvedItem = self.resolveConflict(localItem: item, serverItem: existingItem)
                try? transaction.setData(from: resolvedItem, forDocument: docRef)
            } else {
                transaction.setData(document.data()!, forDocument: docRef)
            }
            
            return nil
        } completion: { (object, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func resolveConflict(localItem: ItemModel, serverItem: ItemModel) -> ItemModel {
        if localItem.timestamp > serverItem.timestamp {
            return localItem
        } else {
            return serverItem
        }
    }
}

extension Notification.Name {
    static let networkConnected = Notification.Name("networkConnected")
}

// MARK: - AdaptiveSyncManager
class AdaptiveSyncManager {
    private let networkMonitor = NetworkMonitor()
    private let itemRepository = ItemRepository()
    private var itemQueue: [ItemModel] = []

    init() {
        loadQueueFromDisk()
        
        // Sync queued items when network becomes available
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .networkConnected, object: nil)
        
        // Initial check in case the app starts with network already available
        if networkMonitor.isConnected {
            syncQueuedItems()
        }
    }
    
    func syncItem(_ item: ItemModel) {
        if networkMonitor.isConnected {
            itemRepository.addItem(item) { result in
                switch result {
                case .success:
                    print("Item synced successfully")
                case .failure(let error):
                    print("Error syncing item: \(error)")
                    self.queueItemForLaterSync(item)
                }
            }
        } else {
            print("Network unavailable, item queued for later sync")
            queueItemForLaterSync(item)
        }
    }
    
    private func queueItemForLaterSync(_ item: ItemModel) {
        itemQueue.append(item)
        saveQueueToDisk()
    }
    
    private func syncQueuedItems() {
        guard networkMonitor.isConnected else { return }
        
        while !itemQueue.isEmpty {
            let item = itemQueue.removeFirst()
            itemRepository.addItem(item) { result in
                switch result {
                case .success:
                    print("Queued item synced successfully")
                case .failure(let error):
                    print("Error syncing queued item: \(error)")
                    self.queueItemForLaterSync(item)
                }
            }
        }
        
        saveQueueToDisk()
    }
    
    private func saveQueueToDisk() {
        do {
            let data = try JSONEncoder().encode(itemQueue)
            UserDefaults.standard.set(data, forKey: "itemQueue")
        } catch {
            print("Failed to save queue: \(error)")
        }
    }
    
    private func loadQueueFromDisk() {
        if let data = UserDefaults.standard.data(forKey: "itemQueue") {
            do {
                itemQueue = try JSONDecoder().decode([ItemModel].self, from: data)
            } catch {
                print("Failed to load queue: \(error)")
            }
        }
    }
    
    @objc private func networkStatusChanged(notification: Notification) {
        syncQueuedItems()
    }
}
