import Foundation
@MainActor
class SearchListViewModel: ObservableObject {
    @Published var groups: [SearchGroup] = [
        SearchGroup(field: "ADDRESS", alias: "Address", features: []),
        SearchGroup(field: "OWNER", alias: "Owner", features: []),
        SearchGroup(field: "PIN_NUM", alias: "PIN", features: []),
        SearchGroup(field: "REID", alias: "REID", features: []),
        SearchGroup(field: "FULL_STREET_NAME", alias: "Street", features: [])
    ]
    
    func search(text: String) async {
        
        
        do {
            for  group in self.groups {
                let features: [SearchFeature] = try await Search().getData(searchTerm: text, field: group.field)
                DispatchQueue.main.async {
                    
                    group.features = features.map(SearchItem.init)
                    
                }
            }
        } catch {
            print(error)
        }
    }
    func updateView(){
        self.objectWillChange.send()
    }
    func handleSearchTextChange(_ value: String) {
        Task {
            if !value.isEmpty && value.count > 3 {
                try? await performSearch(text: value.uppercased())
            } else {
                for group in groups {
                    group.features.removeAll()
                    
                }
            }
            objectWillChange.send()
        }
    }
    
    func performSearch(text: String) async throws {
        do {
            try await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else {
                return
            }
            await search(text: text)
        } catch {
            // Handle the error appropriately
            print("Error performing search: \(error)")
            // Handle or propagate the error if needed
            throw error // Re-throw the error if necessary
        }
    }
 



}

class SearchItem: ObservableObject, Identifiable, Hashable  {
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        return lhs.id == rhs.id
    }
    let id = UUID()
    @Published var feature: SearchFeature
    var text: String {
        feature.attributes.siteAddress ?? feature.attributes.fullStreetName ?? feature.attributes.owner ?? feature.attributes.reid ?? feature.attributes.pin ?? ""
    }
    init(feature: SearchFeature) {
        self.feature = feature
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class SearchGroup: ObservableObject, Identifiable, Hashable {
    static func == (lhs: SearchGroup, rhs: SearchGroup) -> Bool {
        return lhs.id == rhs.id
    }
    let id = UUID()
    let field: String
    let alias: String
    @Published var features: [SearchItem]
    
    init(field: String, alias: String, features: [SearchItem]) {
        self.field = field
        self.alias = alias
        self.features = features
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

