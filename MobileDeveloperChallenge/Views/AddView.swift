//
//  AddView.swift
//  ToDoList
//
//  Created by Denis DRAGAN on 29.10.2023.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State private var textFieldText: String = ""
    @State private var showAlert: Bool = false
    private var alertTitle: String = "Your new todo item must be at least 3 characters long!"
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Type something here...", text: $textFieldText)
                    .padding(.horizontal)
                    .frame(height: 55)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: saveButtonPressed,
                       label: {
                    Text("SAVE")
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                })
                .buttonStyle(.borderedProminent)
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding(14)
            .navigationTitle("Add an Item 🖋️")
        }
    }
    
    func saveButtonPressed() {
        if textIsAppropriate() {
            listViewModel.addItem(title: textFieldText)
            dismiss()
        }
    }
    
    func textIsAppropriate() -> Bool {
        if textFieldText.count < 3 {
            showAlert.toggle()
            return false
        }
        return true
    }
}

#Preview {
    NavigationStack {
        AddView()
    }
    .environmentObject(ListViewModel())
}
