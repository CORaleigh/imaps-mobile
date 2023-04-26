//
//  ContentViewController.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/23/23.
//

import Foundation
import ArcGIS
import SwiftUI

func setLayerVisibility (map: Map, layersLoaded: Bool) async -> Bool {

        try? await map.load()
        if (!layersLoaded) {
            //make all group layers visible by default
            let visibleLayers: Array? = UserDefaults.standard.array(forKey: "visibleLayers") ?? []
            map.operationalLayers.forEach { layer in
                if ((layer as? GroupLayer) != nil) {
                    layer.isVisible = true
                    layer.subLayerContents.forEach { sublayer in
                        if ((sublayer as? GroupLayer) != nil) {
                            sublayer.isVisible = true
                            sublayer.subLayerContents.forEach { sublayer2 in
                                if ((sublayer2 as? GroupLayer) != nil) {
                                    sublayer2.isVisible = true
                                    sublayer2.subLayerContents.forEach { sublayer3 in
                                        if ((sublayer3 as? GroupLayer) != nil) {
                                            sublayer3.isVisible = true
                                        } else if ((sublayer3.name != "Property")) {
                                            sublayer3.isVisible = visibleLayers!.contains{ $0 as? String == sublayer3.name}
                                        }
                                    }
                                } else if ((sublayer2.name != "Property")) {
                                    sublayer2.isVisible = visibleLayers!.contains{ $0 as? String == sublayer2.name}
                                }
                            }
                        } else if ((sublayer.name != "Property")) {
                            sublayer.isVisible = visibleLayers!.contains{ $0 as? String == sublayer.name}
                        }
                    }
                } else if ((layer.name != "Property")) {
                    layer.isVisible = false;
                }
            }
        }
        return true
    
    
}
func getCondos(result: IdentifyLayerResult?, table: ServiceFeatureTable , completion: @escaping ([Feature]) -> Void) async {
        if (result != nil) {
            if ((result?.geoElements.count)! > 0) {
                let params = QueryParameters()
                params.whereClause = "PIN_NUM = '\(unwrap(any: result?.geoElements.first?.attributes["PIN_NUM"]))'"
                print(params.whereClause)
                params.returnsGeometry = false
                let results = try? await (table).queryFeatures(using: params, queryFeatureFields: .loadAll)
                completion(Array(results!.features()))
            }
        }
}

