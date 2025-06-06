import Foundation
import UniformTypeIdentifiers

// Extension to define the UTType for CSV files
extension UTType {
    static var commaSeparatedText: UTType {
        UTType(importedAs: "public.comma-separated-values-text")
    }
}

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

// Helper function to import transactions from CSV
func importTransactionsFromCSV(_ csvString: String) -> [Transaction] {
    var transactions: [Transaction] = []
    
    // Split the CSV string into lines
    let lines = csvString.components(separatedBy: .newlines)
    
    // Skip the header row and process each line
    for i in 1..<lines.count {
        let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
        if line.isEmpty { continue }
        
        // Parse the CSV line
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes = !insideQuotes
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        // Add the last field
        fields.append(currentField)
        
        // Ensure we have all required fields
        guard fields.count >= 6 else { continue }
        
        // Parse fields
        let id = UUID(uuidString: fields[0]) ?? UUID()
        guard let amount = Double(fields[1]) else { continue }
        let title = fields[2]
        let category = fields[3]
        
        // Parse date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: fields[4]) else { continue }
        
        // Parse isExpense
        let isExpense = fields[5].lowercased() == "true"
        
        // Create transaction
        let transaction = Transaction(
            id: id,
            amount: amount,
            title: title,
            category: category,
            date: date,
            isExpense: isExpense
        )
        
        transactions.append(transaction)
    }
    
    return transactions
} 