import SwiftUI
import ArcGIS
@MainActor class Service {
    let layerName: String
    let title: String
    let fields: [String]
    @Published var text: [String]
    var expression: String
    var capitalize: Bool
    init(layerName: String, title: String, fields: [String], text: [String], expression: String, capitalize: Bool) {
        self.layerName = layerName
        self.title = title
        self.fields = fields
        self.text = text
        self.expression = expression
        self.capitalize = capitalize
    }
    
}
struct ServiceCategory: Hashable, Identifiable {
    static func == (lhs: ServiceCategory, rhs: ServiceCategory) -> Bool {
        return true
    }
    var id: UUID { UUID() }
    
    let title: String
    var services: [Service]
    init(title: String, services: [Service]) {
        self.title = title
        self.services = services
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
class ServicesViewModel: ObservableObject {
    @Published var services: [ServiceCategory]
    init(services: [ServiceCategory]) {
        self.services = services
    }
}

func queryServices(for layer: FeatureLayer, propertyFeature: Feature) async throws -> [Feature] {
    let params = QueryParameters()
    params.whereClause = "1=1"
    params.returnsGeometry = false
    var results:[Feature] = []
    do {
        let buffered = GeometryEngine.buffer(around: propertyFeature.geometry!, distance: -1.524)
        params.geometry = buffered
        
        let queryResult = try? await (layer.featureTable! as? ServiceFeatureTable)!.queryFeatures(using: params, queryFeatureFields: .loadAll )
        if queryResult != nil {
            let queryResultFeatures = Array(queryResult!.features())
            if !queryResultFeatures.isEmpty {
                results = queryResultFeatures
            }
        }

    }
    return results
    
}

func queryPollingPlaces(for layer: FeatureLayer, whereClause: String) async throws -> [Feature] {
    let params = QueryParameters()
    params.whereClause = whereClause
    var results:[Feature] = []
    do {
        let queryResult = try? await (layer.featureTable! as? ServiceFeatureTable)!.queryFeatures(using: params, queryFeatureFields: .loadAll )
        let queryResultFeatures = Array(queryResult!.features())
        if !queryResultFeatures.isEmpty {
            results = queryResultFeatures
        }
    }
    return results
    
}



