//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Denis DRAGAN on 29.10.2023.
//

import Foundation

class ListViewModel: ObservableObject {
    
    let syncManager = AdaptiveSyncManager()
    
    @Published var items: [ItemModel] = [] {
        didSet {
            saveItem()
        }
    }
    
    let itemsKey = "items_list"
    
    init() {
        getItems() // Call the 'getItems()' function when the class is initialized.
    }
    // Fetches data from UserDefaults and assigns it to the 'items' array.
    func getItems() {
        guard
            let data = UserDefaults.standard.data(forKey: itemsKey),
            let savedItems = try? JSONDecoder().decode([ItemModel].self, from: data)
        else { return }
        
        self.items = savedItems
    }
    
    func deleteItem(index: IndexSet) {
        items.remove(atOffsets: index) // Perform item deletion at the specified index.
    }
    
    func moveItem(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to) // Perform item moving from one index to another.
    }
    
    func addItem(title: String) {
        let newItem = ItemModel(title: title, isCompleted: false)
        items.append(newItem)
    }
    
    func updateItem(item: ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item.updateCompletion()
        }
    }
    // Saves the 'items' array to UserDefaults.
    func saveItem() {
        if let encodeData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.setValue(encodeData, forKey: itemsKey)
        }
    }
    
    func saveItemToCloudFirestore(){
        
        let item = ItemModel(title: "Buy Groceries", isCompleted: false)

        // Simulate a situation where you modify the item and then sync it
        syncManager.syncItem(item)

        // Later, another device/user modifies the same item and it is synced to the server
        let serverItem = ItemModel(id: item.id, title: "Buy Groceries and Milk", isCompleted: true, timestamp: Date().addingTimeInterval(-60)) // older timestamp

        // Now, when you update the item again, the conflict resolution strategy will ensure that the most recent changes are kept
        let updatedItem = item.updateCompletion()
        syncManager.syncItem(updatedItem)  // The newer item will overwrite the older one based on the timestamp
    }
}
