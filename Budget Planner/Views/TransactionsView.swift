//
//  TransactionsView.swift
//  Budget Planner
//
//  Created on Phase 2
//

import SwiftUI

struct TransactionsView: View {
    @Environment(BudgetModel.self) private var model
    @State private var showAddTransaction = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredTransactions.isEmpty {
                    EmptyTransactionsView()
                        .padding(.top, 50)
                } else {
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                Button(action: {
                    showAddTransaction = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(model: model)
            }
            .searchable(text: $searchText, prompt: "Search transactions")
        }
    }
    
    private var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return model.transactions
        } else {
            return model.transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.categoryEnum.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        model.deleteTransactions(at: offsets)
    }
} 