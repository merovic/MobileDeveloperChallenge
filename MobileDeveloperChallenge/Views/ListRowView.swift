//
//  ListRowView.swift
//  ToDoList
//
//  Created by Denis DRAGAN on 29.10.2023.
//

import SwiftUI

struct ListRowView: View {
    let item: ItemModel
    
    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                .foregroundStyle(item.isCompleted ? .green : .red)
            Text(item.title)
                .accessibilityLabel("Submit Button")
                .accessibilityHint("Sends the form data")
            Spacer()
        }
    }
}
