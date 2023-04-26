//
//  PropertyInfoView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/26/23.
//

import SwiftUI
import ArcGIS

struct PropertyInfoView: View {
    @EnvironmentObject var dataModel : MapDataModel

    @State var feature: Feature
    @State var fromSearch: Bool
    @State var popped: Bool = false
    @ObservedObject private var propertyInfoVM: PropertyInfoViewModel = PropertyInfoViewModel(deed: nil, photos: [], property: nil)
   // var propertySelected : (Feature) -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(feature.attributes["SITE_ADDRESS"] as? String ?? "")
                        .font(.largeTitle)
                    GeneralView(attributes: feature.attributes)
                    OwnerView(attributes: feature.attributes)
                    ValuationView(attributes: feature.attributes)
                    SaleView(attributes: feature.attributes)
                    DeedView(attributes: feature.attributes, deed: propertyInfoVM.deed ?? [:])
                        .onAppear {
                            Task {
                                let table: ServiceFeatureTable = await dataModel.getCondoTable(map: dataModel.map)!
                                await propertyInfoVM.getDeeds(for: table , feature: feature as? ArcGISFeature, completion: { result in
                                    let d = result.first(where: {$0 != nil})
                                    DispatchQueue.main.async {
                                        self.propertyInfoVM.deed = d!.attributes
                                    }
                                })
                            }
                            
                        }
                    BuildingView(attributes:feature.attributes)
                    PhotoView(photos: propertyInfoVM.photos)
                        .onAppear {
                            Task {
                                let table: ServiceFeatureTable = await dataModel.getCondoTable(map: dataModel.map)!
                                await propertyInfoVM.getPhotos(for: table , feature: feature as? ArcGISFeature, completion: { results in
                                    //photos = []
                                    for result in results {
                                        DispatchQueue.main.async {
                                            propertyInfoVM.photos.append(result.attributes)
                                        }
                                    }
                                })
                            }
                        }
                }
                .onAppear {
                    Task {
                        
                        if !popped {
                            let table: ServiceFeatureTable = await dataModel.getCondoTable(map: dataModel.map)!
                            await propertyInfoVM.getProperty(id: Int(self.feature.attributes["OBJECTID"] as! Int64), table: table, completion: { property in
                                //self.propertySelected(property!)
                                dataModel.propertySelected(map: dataModel.map, property: property!)
                            })
                            
                            popped = true
                            
                        }
                        
                    }
                    
                }
            }
                .navigationTitle("Property")
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)

    }

}

//struct PropertyInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyInfoView()
//    }
//}
