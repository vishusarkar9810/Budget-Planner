//
//  AddTransactionView.swift
//  Budget Planner
//
//  Created on Phase 2
//

import SwiftUI

struct AddTransactionView: View {
    let model: BudgetModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var title = ""
    @State private var category = BudgetCategory.food.rawValue
    @State private var date = Date()
    @State private var isExpense = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(BudgetCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .foregroundColor(category.color)
                                .tag(category.rawValue)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveTransaction) {
                        Text("Save Transaction")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                    .disabled(!isFormValid)
                    .listRowBackground(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount), !title.isEmpty else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            title: title,
            category: category,
            date: date,
            isExpense: isExpense
        )
        
        model.addTransaction(transaction)
        dismiss()
    }
} 