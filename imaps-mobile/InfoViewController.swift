//
//  InfoViewController.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/23/23.
//

import Foundation
import ArcGIS
import SwiftUI
func getProperty(id: Int, table: ArcGISFeatureTable, map: Map, viewpoint: Viewpoint, graphicsOverlay: GraphicsOverlay, proxy: MapViewProxy) async {
    let params = QueryParameters()
    params.addObjectID(id)
    await queryProperty(for: table, params: params) { features in
        let feature = features.first(where: {$0.geometry != nil})
       // let envelope = EnvelopeBuilder(envelope: feature?.geometry!.extent)
       // envelope.expand(factor: 2)
        //shared.viewpoint = Viewpoint(targetExtent:envelope.extent)
        Task {
            if (feature != nil) {
                await proxy.setViewpointGeometry((feature?.geometry)!, padding: 100)

            }
        }


        
        graphicsOverlay.removeAllGraphics()
        graphicsOverlay.addGraphic(Graphic(geometry: feature?.geometry, attributes: feature!.attributes, symbol: SimpleFillSymbol(style: SimpleFillSymbol.Style.noFill, outline: SimpleLineSymbol(style: SimpleLineSymbol.Style.solid, color: UIColor.red, width: 2))))
    }
}

func queryProperty(for table: ArcGISFeatureTable, params: QueryParameters, completion: @escaping (AnySequence<Feature>) -> Void) async {
    let result = try? await table.queryFeatures(using: params)
    result?.features().forEach({ feature in
         Task {
            let relInfo = table.layerInfo?.relationshipInfos.filter { $0.name.contains("PROPERTY") }
            let relatedParams  = RelatedQueryParameters(relationshipInfo: (relInfo?.first)! as RelationshipInfo)
        let relatedResults = try? await table.queryRelatedFeatures(to: feature as! ArcGISFeature, using: relatedParams)

        relatedResults?.forEach({ result in
            if ((result.relatedTable?.tableName.contains("Property")) != nil) {
                completion(result.features())
            }
        })
        }
        })
}


func getDeeds(for table: ServiceFeatureTable, feature: ArcGISFeature?, completion: @escaping (AnySequence<Feature>) -> Void) async {
    try? await table.load()
    let relInfo = table.layerInfo?.relationshipInfos.filter { $0.name.contains("BOOK") }
    let relatedParams  = RelatedQueryParameters(relationshipInfo: (relInfo?.first)! as RelationshipInfo)
    let relatedResults = try? await table.queryRelatedFeatures(to: feature!, using: relatedParams, queryFeatureFields: .loadAll)
    relatedResults?.forEach({ result in
        if ((result.relatedTable?.tableName.contains("Books")) != nil) {
            completion(result.features())
        }
    })
}
func getPhotos(for table: ServiceFeatureTable, feature: ArcGISFeature?, completion: @escaping (AnySequence<Feature>) -> Void) async {
    try? await table.load()

    let relInfo = table.layerInfo?.relationshipInfos.filter { $0.name.contains("PHOTOS") }
    let relatedParams  = RelatedQueryParameters(relationshipInfo: (relInfo?.first)! as RelationshipInfo)
    let relatedResults = try? await table.queryRelatedFeatures(to: feature!, using: relatedParams, queryFeatureFields: .loadAll)
    relatedResults?.forEach({ result in
        if ((result.relatedTable?.tableName.contains("Photos")) != nil) {
            completion(result.features())
        }
    })
}
struct PropertyDetails {
    var photos: [[String: Any]]
    var deed: [String: Any]
    init(photos: [[String: Any]], deed: [String: Any]) {
        self.photos = photos
        self.deed = deed
    }
}
func getPropertyDetails(feature: Feature?, fromSearch: Bool, viewpoint: Viewpoint, table: ServiceFeatureTable, graphics: GraphicsOverlay, map: Map, proxy: MapViewProxy) async -> PropertyDetails {
   // Task {
        var deed: [String: Any]? = nil
        var photos: [[String: Any]] = []
        if (fromSearch == false) {
            let encoder = JSONEncoder()
            let history = updateStorageHistory(field: "SITE_ADDRESS", value:feature?.attributes["SITE_ADDRESS"] as! String)
            if let encoded = try? encoder.encode(history) {
                UserDefaults.standard.set(encoded, forKey: "searchHistory")
            }
        }

        
    await getDeeds(for: table , feature: feature as? ArcGISFeature, completion: { result in
            let d = result.first(where: {$0 != nil})

            deed = d!.attributes
        })
    await getPhotos(for: table , feature: feature as? ArcGISFeature, completion: { results in
            //photos = []
            for result in results {
                photos.append(result.attributes)
            }
            photos = photos

        })
    await getProperty(id: Int(feature?.attributes["OBJECTID"] as! Int64), table: table as ArcGISFeatureTable, map: map, viewpoint: viewpoint, graphicsOverlay: graphics, proxy: proxy)
    return PropertyDetails(photos: photos, deed: deed!)
 //   }
}
