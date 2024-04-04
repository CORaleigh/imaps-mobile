import Foundation
import ArcGIS

class ViewModel: ObservableObject {
    @Published var text: String
    init(text: String) {
        self.text = text
    }
}
class PropertyViewModel: ObservableObject {
    @Published var feature: Feature?
    @Published var features: [Feature]
    @Published var text: String = ""
    init(feature: Feature?, features: [Feature]) {
        self.feature = feature
        self.features = features
    }
    func updateView(){
        self.objectWillChange.send()
    }
    
}

class FeatureViewModel: ObservableObject {
    @Published var feature: Feature?
    init(feature: Feature?) {
        self.feature = feature
    }
}

enum PropertySource {
    case search, map, history
}

func queryFeatures(for table: ServiceFeatureTable, field: String, value: String, completion: @escaping ([Feature]) -> Void) async {
    let params = QueryParameters()
    params.whereClause = "\(field) = '\(value)'"
    params.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
    guard let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll) else { return }
    completion(Array((result.features())))
}
