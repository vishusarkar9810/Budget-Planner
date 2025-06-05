import Foundation

// Helper struct for encoding Transaction data
struct TransactionExport: Encodable {
    let id: String
    let amount: Double
    let title: String
    let category: String
    let date: Double // timestamp
    let isExpense: Bool
    
    init(from transaction: Transaction) {
        self.id = transaction.id.uuidString
        self.amount = transaction.amount
        self.title = transaction.title
        self.category = transaction.category
        self.date = transaction.date.timeIntervalSince1970
        self.isExpense = transaction.isExpense
    }
}

// Helper function to export transactions
func exportTransactionsToCSV(_ transactions: [Transaction]) -> String {
    var csvString = "ID,Amount,Title,Category,Date,IsExpense\n"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    for transaction in transactions {
        // Escape quotes in the title by doubling them
        let safeTitle = transaction.title.replacingOccurrences(of: "\"", with: "\"\"")
        
        // Build a CSV row
        let row = "\(transaction.id.uuidString),\(transaction.amount),\"\(safeTitle)\",\(transaction.category),\(dateFormatter.string(from: transaction.date)),\(transaction.isExpense ? "true" : "false")\n"
        csvString.append(row)
    }
    
    return csvString
} 