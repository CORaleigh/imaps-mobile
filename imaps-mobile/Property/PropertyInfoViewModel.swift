import Foundation
import SwiftUI
import ArcGIS

class PropertyInfoViewModel: ObservableObject {
    @Published var deed: [String: Any]?
    @Published var photos: [[String: Any]]
    @Published var property: Feature?
    
    init(deed: [String: Any]?, photos: [[String:Any]], property: Feature?) {
        self.deed = deed
        self.photos = photos
        self.property = property
    }
    func updateView(){
        self.objectWillChange.send()
    }
    
    func queryFeatures(for table: ServiceFeatureTable, field: String, value: String, completion: @escaping (AnySequence<Feature>) -> Void) async {
        let params = QueryParameters()
        params.whereClause = "\(field) = '\(value)'"
        params.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
        let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll)
        completion((result?.features())!)
    }
    func getDeeds(for table: ServiceFeatureTable, feature: ArcGISFeature, relationshipInfo: RelationshipInfo, completion: @escaping ([Feature]) -> Void) async {
        let relatedParams  = RelatedQueryParameters(relationshipInfo: relationshipInfo)
        let relatedResults = try? await table.queryRelatedFeatures(to: feature, using: relatedParams, queryFeatureFields: .loadAll)
        relatedResults?.forEach({ result in
            if ((result.relatedTable?.tableName.contains("Books")) != nil) {
                completion(Array(result.features()))
            }
        })
    }
    func getPhotos(for table: ServiceFeatureTable, feature: ArcGISFeature, relationshipInfo: RelationshipInfo, completion: @escaping (AnySequence<Feature>) -> Void) async {
        let relatedParams  = RelatedQueryParameters(relationshipInfo: relationshipInfo)
        relatedParams.addOrderByField(OrderBy(fieldName: "DATECREATED", sortOrder: .descending))
        let relatedResults = try? await table.queryRelatedFeatures(to: feature, using: relatedParams, queryFeatureFields: .loadAll)
        relatedResults?.forEach({ result in
            if ((result.relatedTable?.tableName.contains("Photos")) != nil) {
                completion(result.features())
            }
        })
    }
    func getProperty(id: Int, table: ArcGISFeatureTable, relationshipInfo: RelationshipInfo, completion: @escaping (Feature?) -> Void) async {
        let params = QueryParameters()
        params.addObjectID(id)
        await queryProperty(for: table, params: params, relationshipInfo: relationshipInfo) { features in
            let feature = features.first(where: {$0.geometry != nil})
            completion(feature)
        }
    }
    
    func queryProperty(for table: ArcGISFeatureTable, params: QueryParameters, relationshipInfo: RelationshipInfo, completion: @escaping (AnySequence<Feature>) -> Void) async {
        let result = try? await table.queryFeatures(using: params)
        result?.features().forEach({ feature in
            Task {
                let relatedParams  = RelatedQueryParameters(relationshipInfo: relationshipInfo)
                let relatedResults = try? await table.queryRelatedFeatures(to: feature as! ArcGISFeature, using: relatedParams)
                
                relatedResults?.forEach({ result in
                    if ((result.relatedTable?.tableName.contains("Property")) != nil) {
                        completion(result.features())
                    }
                })
            }
        })
    }
}
