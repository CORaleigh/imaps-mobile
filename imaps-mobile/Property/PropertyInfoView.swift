import SwiftUI
import ArcGIS

struct PropertyInfoView: View, Equatable {
    @ObservedObject var mapViewModel : MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var feature: FeatureViewModel
    @State private var servicesActive = false
    @ObservedObject private var propertyInfoVM: PropertyInfoViewModel = PropertyInfoViewModel(deed: nil, photos: [], property: nil)
    
    static func == (lhs: PropertyInfoView, rhs: PropertyInfoView) -> Bool {
        
        return lhs.feature.feature.attributes["REID"] as? String == rhs.feature.feature.attributes["REID"] as? String
    }
    var body: some View {
        ScrollView {
            ZStack {
                VStack{
                    let address = formatAddress(address:(feature.feature.attributes["SITE_ADDRESS"] as? String ?? "") + " " + (feature.feature.attributes["STMISC"] as? String ?? ""))

                    Text(address)
                        .font(.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.all)
                    
                    GeneralView(attributes: feature.feature.attributes)
                    OwnerView(attributes: feature.feature.attributes)
                    ValuationView(attributes: feature.feature.attributes)
                    SaleView(attributes: feature.feature.attributes)
                    DeedView(panelVM: panelVM, attributes: feature.feature.attributes, deed: propertyInfoVM.deed ?? [:])
                        .onReceive(feature.$feature) { feature in
                            Task {
                                let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map)!
                                guard let relInfo = table.layerInfo?.relationshipInfos.filter({ $0.name.contains("BOOK") }).first else { return }
                                await propertyInfoVM.getDeeds(for: table , feature: feature as! ArcGISFeature, relationshipInfo: relInfo, completion: { result in
                                    if !result.isEmpty {
                                        let d = result.first
                                        DispatchQueue.main.async {
                                            self.propertyInfoVM.deed = d!.attributes
                                        }
                                    }
                                    
                                })
                            }
                            
                        }
                    BuildingView(attributes:feature.feature.attributes)
                    TaxInfoView(panelVM: self.panelVM, attributes: feature.feature.attributes)

                    
                    Button {
                        self.servicesActive = true
                    }
                label: {
                    HStack {
                        Image(systemName: "doc")
                        Text("Services")
                    }                        .frame(maxWidth: .infinity)
                       
                    
                }
                .padding(.horizontal, 10)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .navigationDestination(isPresented: $servicesActive) {
                    Services(mapViewModel: mapViewModel, propertyInfoViewModel: self.propertyInfoVM)
                        .navigationTitle("Services")
                }

                    PhotoView(photos: propertyInfoVM.photos)
                        .onReceive(feature.$feature) { feature in
                            Task {
                                guard let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
                                guard let relInfo = table.layerInfo?.relationshipInfos.filter({ $0.name.contains("PHOTO") }).first else { return }
                                await propertyInfoVM.getPhotos(for: table , feature: feature as! ArcGISFeature, relationshipInfo: relInfo, completion: { results in
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
            
            .onReceive(panelVM.$selectedPinNum) { selectedPinNum in
                self.servicesActive = false
            }
            .onReceive(feature.$feature) { feature in
 
                Task {
                    guard let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map),
                          let oid = feature.attributes["OBJECTID"],
                          let relInfo = table.layerInfo?.relationshipInfos.filter({ $0.name.contains("PROPERTY") }).first
                    else { return }
                    await propertyInfoVM.getProperty(id: Int(oid as! Int64), table: table, relationshipInfo: relInfo,  completion: { property in
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
            ToolbarItem (placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://maps.raleighnc.gov/imaps-mobile?address=\(feature.feature.attributes["SITE_ADDRESS"] ?? "")&pin=\(feature.feature.attributes["PIN_NUM"] ?? "")")!, subject: Text("View \(feature.feature.attributes["SITE_ADDRESS"] ?? "") in iMAPS"), message: Text("View \(feature.feature.attributes["SITE_ADDRESS"] ?? "") in iMAPS"), preview: SharePreview("View \(feature.feature.attributes["SITE_ADDRESS"] ?? "") in iMAPS", image: Image("imaps"))) {
                        Image(systemName: "square.and.arrow.up")
                    }
                
            }
            ToolbarItem (placement: .topBarTrailing){

                Button(action: {
                    self.panelVM.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
        .toolbarBackground(.visible)
        .toolbarBackground(Color("Background").opacity(0.5))
        
    }
    
    
    
    
}

func formatAddress (address: String) -> String {
    var value:String = address
    if value.hasSuffix("1/2") {
        if let range = value.range(of:" ") {
            value = value.replacingCharacters(in: range, with:" 1/2 ")
            value.removeLast(3)
         }
    }
    return value
}
//struct PropertyInfoView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        PropertyInfoView(feature: FeatureModel(feature: ), fromSearch: false, fromList: false)
//    }
//}
