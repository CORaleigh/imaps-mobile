//
//  Utilities.swift
//  layout-test
//
//  Created by Greco, Justin on 4/26/23.
//

import Foundation

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
    if let json = UserDefaults.standard.value(forKey: "searchHistory") as? Data {
        let decoder = JSONDecoder()
        if var jsonDecoded = try? decoder.decode(SearchHistory.self, from: json) as SearchHistory {
            if (jsonDecoded.historyItems.count == 10) {
                jsonDecoded.historyItems.removeFirst()
            }
            var index = jsonDecoded.historyItems.firstIndex(where: {$0.field == field && $0.value == value})
            if index != nil {
                jsonDecoded.historyItems.remove(at: index!)
            }
            jsonDecoded.historyItems.append(HistoryItem(field: field, value: value))
           // jsonDecoded.historyItems = []
            return jsonDecoded
        } else {
            return SearchHistory(historyItems: [HistoryItem(field: field, value: value)])
        }
    } else {
        return SearchHistory(historyItems: [HistoryItem(field: field, value: value)])
    }
}
