import Foundation
import Network
import ArcGISToolkit

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}
func unwrap(any:Any?) -> Any {
    
    let mi = Mirror(reflecting: any as Any)
    if mi.displayStyle != .optional {
        return any as Any
    }
    
    if mi.children.count == 0 { return NSNull() }
    let (_, some) = mi.children.first!
    return some
    
}

func formatDate(date: Date) -> String {
    return date.formatted(date: .numeric, time: .omitted)
}

struct HistoryItem: Codable, Hashable {
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.value == rhs.value
    }
    var field: String
    var value: String
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}


class SearchHistoryModel: ObservableObject {
    @Published var history: SearchHistory
    init(history: SearchHistory) {
        self.history = history
    }
}

struct SearchHistory: Encodable, Decodable {
    
    var historyItems: [HistoryItem]
}


func getSearchHistory() -> SearchHistory {
    if let json = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let decoder = JSONDecoder()
        if let jsonDecoded = try? decoder.decode(SearchHistory.self, from: json) as SearchHistory {
            return jsonDecoded
        } else {
            return SearchHistory(historyItems: [])
        }
    } else {
        return SearchHistory(historyItems: [])
        
    }
}

func updateStorageHistory(field: String, value: String) -> SearchHistory {
    // Ensure the field and value are not empty
    guard !field.isEmpty && !value.isEmpty else {
        return SearchHistory(historyItems: [])
    }

    do {
        if let json = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
            let decoder = JSONDecoder()
            var jsonDecoded = try decoder.decode(SearchHistory.self, from: json)
            
            // Remove oldest history item if the count exceeds 10
            if jsonDecoded.historyItems.count == 10 {
                jsonDecoded.historyItems.removeFirst()
            }
            
            // Remove existing history item if found
            if let index = jsonDecoded.historyItems.firstIndex(where: { $0.field == field && $0.value == value }) {
                jsonDecoded.historyItems.remove(at: index)
            }
            
            // Append new history item
            jsonDecoded.historyItems.append(HistoryItem(field: field, value: value))
            
            return jsonDecoded
        } else {
            // Initialize new search history if no existing history found
            return SearchHistory(historyItems: [HistoryItem(field: field, value: value)])
        }
    } catch {
        // Handle decoding errors
        print("Error decoding search history:", error)
        return SearchHistory(historyItems: [])
    }
}



class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}



extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
