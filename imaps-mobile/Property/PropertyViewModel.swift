import Foundation
import ArcGIS

class ViewModel: ObservableObject {
    @Published var text: String
    init(text: String) {
        self.text = text
    }
}
class PropertyFeature: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    @Published var feature: Feature
    @Published var isPresented: Bool = false
    static func == (lhs: PropertyFeature, rhs: PropertyFeature) -> Bool {
        return lhs.id == rhs.id
    }
    init(feature: Feature) {
        self.feature = feature
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
class PropertyViewModel: ObservableObject {
    @Published var feature: Feature?
    @Published var features: [PropertyFeature]
    @Published var text: String = ""
    init(feature: Feature?, features: [PropertyFeature]) {
        self.feature = feature
        self.features = features
    }
    func updateView(){
        self.objectWillChange.send()
    }
    
}

class FeatureViewModel: ObservableObject {
    @Published var feature: Feature
    init(feature: Feature) {
        self.feature = feature
    }
}

enum PropertySource {
    case search, map, history
}

func queryFeatures(for table: ServiceFeatureTable, field: String, value: String, completion: @escaping ([Feature]) -> Void) async {
    let params = QueryParameters()
    params.whereClause = "\(field) = '\(value)'"
    if field == "ADDRESS" {
        params.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
        params.addOrderByField(OrderBy(fieldName: "STMISC", sortOrder: .ascending))
    }
    if field == "PIN_NUM" {
        params.addOrderByField(OrderBy(fieldName: "PIN_EXT", sortOrder: .ascending))
    }
    else {
        params.addOrderByField(OrderBy(fieldName: field, sortOrder: .ascending))
    }

    guard let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll) else { return }
    completion(Array((result.features())))
}

func queryRelatedCondos(for addressTable: ServiceFeatureTable, relationshipInfo: RelationshipInfo, address: String, completion: @escaping ([Feature]) -> Void) async {
    let params = QueryParameters()
    params.whereClause = "ADDRESS = '\(address)'"
    params.returnsGeometry = false
    params.addOrderByField(OrderBy(fieldName: "ADDRESS", sortOrder: .ascending))
    guard let result = try? await addressTable.queryFeatures(using: params, queryFeatureFields:.idsOnly) else { return }
    if Array(result.features()).count > 0 {
        guard let feature = Array(result.features()).first else { return }
        let relatedParams = RelatedQueryParameters(relationshipInfo: relationshipInfo)
        relatedParams.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
        relatedParams.addOrderByField(OrderBy(fieldName: "STMISC", sortOrder: .ascending))

        relatedParams.whereClause = "1=1"
        guard let result = try? await addressTable.queryRelatedFeatures(to: feature as! ArcGISFeature, using: relatedParams, queryFeatureFields: .loadAll) else { return }
        if !result.isEmpty {
            completion(Array((result.first?.features())!))
        }
    }
    
    

    
}

