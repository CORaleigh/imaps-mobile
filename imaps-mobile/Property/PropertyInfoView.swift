import SwiftUI
import ArcGIS

struct PropertyInfoView: View, Equatable {
    @EnvironmentObject var mapViewModel : MapViewModel
    @EnvironmentObject var panelVM: PanelViewModel
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var feature: FeatureViewModel
    @State var fromSearch: Bool
    @State var fromList: Bool
    
    @ObservedObject private var propertyInfoVM: PropertyInfoViewModel = PropertyInfoViewModel(deed: nil, photos: [], property: nil)
    
    static func == (lhs: PropertyInfoView, rhs: PropertyInfoView) -> Bool {
        
        return lhs.feature.feature?.attributes["REID"] as? String == rhs.feature.feature?.attributes["REID"] as? String
    }
    var body: some View {
        ScrollView {
            ZStack {
                VStack{

                    Text(feature.feature?.attributes["SITE_ADDRESS"] as? String ?? "")
                        .font(.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.all)
                    
                    GeneralView(attributes: feature.feature!.attributes)
                    OwnerView(attributes: feature.feature!.attributes)
                    ValuationView(attributes: feature.feature!.attributes)
                    SaleView(attributes: feature.feature!.attributes)
                    DeedView(attributes: feature.feature!.attributes, deed: propertyInfoVM.deed ?? [:])
                        .onReceive(feature.$feature) { feature in
                            Task {
                                let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map)!
                                await propertyInfoVM.getDeeds(for: table , feature: feature as? ArcGISFeature, completion: { result in
                                    if !result.isEmpty {
                                        let d = result.first
                                        DispatchQueue.main.async {
                                            self.propertyInfoVM.deed = d!.attributes
                                        }
                                    }
                                    
                                })
                            }
                            
                        }
                    BuildingView(attributes:feature.feature!.attributes)
                    TaxInfoView(attributes: feature.feature!.attributes)
                    NavigationLink(destination: {
                        ServicesView(feature: feature, layers: []).environmentObject(mapViewModel).environmentObject(propertyInfoVM)
                        
                            .navigationTitle("Services")
                    },
                                   label: {
                        HStack {
                            Image(systemName: "doc")
                            Text("Services")
                        }
                        
                        .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    PhotoView(photos: propertyInfoVM.photos)
                        .onReceive(feature.$feature) { feature in
                            Task {
                                guard let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
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
            }
            
                .onReceive(feature.$feature) { feature in
                    print(feature as Any)
                    Task {
                        guard let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map),
                              let oid = feature?.attributes["OBJECTID"]
                        else { return }
                        await propertyInfoVM.getProperty(id: Int(oid as! Int64), table: table, completion: { property in
                            //self.propertySelected(property!)
                            if property != nil {
                                mapViewModel.propertySelected(map: mapViewModel.map, property: property!)
                                DispatchQueue.main.async {
                                    propertyInfoVM.property = property
                                }
                            }
                            
                        })
                    }
                }
        }
        .scrollContentBackground(.hidden)
        .background(Color("Background"))
        .navigationTitle("Property")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem (placement: .navigationBarTrailing){
                Button(action: {
                    self.panelVM.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
        
    }
    
    
    
    
}

//struct PropertyInfoView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        PropertyInfoView(feature: FeatureModel(feature: ), fromSearch: false, fromList: false)
//    }
//}
