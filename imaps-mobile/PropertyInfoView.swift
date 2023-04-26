//
//  PropertyInfoView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS
struct PropertyInfoView: View {
    
    @EnvironmentObject  var shared: SharedData
    let value: ListValue
    @State private var feature: Feature? = nil
    @State  var source: String
    @State private var features: [Feature]  = []
    var body: some View {
        VStack {
            if (features.count == 1) {
                NavigationView {
                    InfoView(feature: self.feature, fromSearch: true)
                }
                    .navigationTitle("Property")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(.stack)


            } else if (features.count > 1) {
                NavigationView {
                    PropertyListView(features: self.features, fromSearch: true)
                }
                    .navigationTitle("Property List")
                    .navigationBarTitleDisplayMode(.inline)
                    
                
            }
        }
        .onAppear()  {
            Task {
                let params1 = QueryParameters()
                let encoder = JSONEncoder()
                if (self.source == "search") {
                    let history = updateStorageHistory(field: value.field, value: value.value)
                    if let encoded = try? encoder.encode(history) {
                        UserDefaults.standard.set(encoded, forKey: "searchHistory")
                    }
                    
                }

                params1.whereClause = "\(value.field) = '\(value.value)'"
                params1.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
                await queryFeatures(for: value.table, params: params1, completion: { data in
                    Task {
                        let count = Array(data).count
                        self.features = []

                        if (count == 1) {
                            let f = data.first(where: {$0.attributes["OBJECTID"] as? Int64 != nil})
                            self.feature = f!
                            data.forEach {
                                feature in
                                self.features.append(feature)
                            }

      
                        } else {
                            data.forEach {
                                feature in
                                self.features.append(feature)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func queryFeatures(for table: ServiceFeatureTable, params: QueryParameters, completion: @escaping (AnySequence<Feature>) -> Void) async {
        let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll)
        completion((result?.features())!)
    }

    func queryCondo(for table: ServiceFeatureTable, params: QueryParameters, completion: @escaping (AnySequence<Feature>) -> Void) async {
        let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll)
        completion((result?.features())!)
    }
    func getProperty(id: Int, table: ArcGISFeatureTable, map: Map, viewpoint: Viewpoint, graphicsOverlay: GraphicsOverlay) async {
        let params = QueryParameters()
        params.addObjectID(id)
        await queryProperty(for: table, params: params) { features in
            let feature = features.first(where: {$0.geometry != nil})
            Task {
                await shared.proxy?.setViewpointGeometry((feature?.geometry)!)

            }
            //shared.viewpoint = Viewpoint(targetExtent:(feature?.geometry)!)
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
    

}

//struct PropertyInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyInfoView(value: ListValue(id: nil, objectid: 0, value: "", table: FeatureTable())
//    }
//}
