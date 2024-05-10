import Foundation
import SwiftUI
import ArcGIS

@MainActor
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
        if let features = result?.features() {
            completion(AnySequence(features))
        }
    }
    func getDeeds(for table: ServiceFeatureTable, feature: ArcGISFeature, relationshipInfo: RelationshipInfo, completion: @escaping ([Feature]) -> Void) async throws{
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
        guard let result = try? await table.queryFeatures(using: params) else {
            // Handle the error if needed
            return
        }

        var relatedFeatures: [Feature] = []
        for feature in result.features() {
            do {
                let relatedParams = RelatedQueryParameters(relationshipInfo: relationshipInfo)
                let relatedResults = try await table.queryRelatedFeatures(to: feature as! ArcGISFeature, using: relatedParams)
                for relatedResult in relatedResults {
                    if relatedResult.relatedTable?.tableName.contains("Property") == true {
                        relatedFeatures.append(contentsOf: relatedResult.features())
                    }
                }
            } catch {
                print("Error querying related features:", error)
                // Handle or propagate the error as needed
            }
        }

        completion(AnySequence(relatedFeatures))
    }

}
