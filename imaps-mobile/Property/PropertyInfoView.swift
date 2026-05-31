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
                        .onReceive(feature.$feature) { (feature: Feature?) in
                            guard let feature = feature else { return }

                            // Check if feature can be converted to ArcGISFeature
                            if let arcgisFeature = feature as? ArcGISFeature {
                                Task {
                                    guard let table = mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
                                    guard let relInfo = table.layerInfo?.relationshipInfos.first(where: { $0.name.contains("BOOK") }) else { return }

                                    do {
                                        _ = try await propertyInfoVM.getDeeds(for: table, feature: arcgisFeature, relationshipInfo: relInfo) { result in
                                            DispatchQueue.main.async {
                                                if let d = result.first {
                                                    self.propertyInfoVM.deed = d.attributes
                                                }
                                            }
                                        }
                                    } catch {
                                        print("Error performing search: \(error)")
                                        // Handle or propagate the error if needed
                                    }
                                }
                            } else {
                                print("Failed to convert Feature to ArcGISFeature")
                                // Handle the failure to convert if needed
                            }
                        }




                    BuildingView(attributes:feature.feature.attributes)
                    TaxInfoView(panelVM: self.panelVM, attributes: feature.feature.attributes)

                    if let septicPermitId = propertyInfoVM.septicPermitId {
                        Button {
                            if let url = URL(string: "https://wakecountync-energovpub.tylerhost.net/apps/SelfService#/permit/\(septicPermitId)"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc")
                                Text("Septic Permit")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 10)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }

                    
                    Button {
                        self.servicesActive = true
                    }
                    label: {
                    HStack {
                        Image(systemName: "flag")
                        Text("Services")
                    }
                    .frame(maxWidth: .infinity)
                       
                    
                }
                .padding(.horizontal, 10)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .navigationDestination(isPresented: $servicesActive) {
                    Services(mapViewModel: mapViewModel, propertyInfoViewModel: self.propertyInfoVM)
                        .navigationTitle("Services")
                        .toolbar {
                            FullscreenButton(panelVM: panelVM)
                        }
                }

                    PhotoView(photos: propertyInfoVM.photos)
                        .onReceive(feature.$feature) { feature in
                            Task {
                                guard let table = mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
                                guard let relInfo = table.layerInfo?.relationshipInfos.first(where: { $0.name.contains("PHOTO") }) else { return }

                                if let arcGISFeature = feature as? ArcGISFeature {
                                    do {
                                        await propertyInfoVM.getPhotos(for: table, feature: arcGISFeature, relationshipInfo: relInfo) { results in
                                            for result in results {
                                                DispatchQueue.main.async {
                                                    propertyInfoVM.photos.append(result.attributes)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("Feature is not of type ArcGISFeature")
                                    // Handle or propagate the error as needed
                                }
                            }
                        }


                }
                
            }
            
            .onReceive(panelVM.$selectedPinNum) { selectedPinNum in
                self.servicesActive = false
            }
            .onReceive(feature.$feature) { feature in
 
                Task {
                    // Safely unwrap table, oid, and relInfo using guard statements
                    guard let table: ServiceFeatureTable = mapViewModel.getCondoTable(map: mapViewModel.map),
                          let oid = feature.attributes["OBJECTID"] as? Int64, // Ensure oid is of type Int64
                          let relInfo = table.layerInfo?.relationshipInfos.first(where: { $0.name.contains("PROPERTY") })
                    else {
                        return
                    }
                    
                    // Await propertyInfoVM.getProperty call and handle the result
                    await propertyInfoVM.getProperty(id: Int(oid), table: table, relationshipInfo: relInfo) { property in
                        // Use Task to handle async code within the completion handler
                        Task {
                            if let property = property {
                                // Handle successful property retrieval
                                mapViewModel.propertySelected(map: mapViewModel.map, property: property)
                                
                                DispatchQueue.main.async {
                                    propertyInfoVM.property = property
                                }
                                
                                // Safely unwrap septicLayer
                                guard let septicLayer = mapViewModel.getSepticPermitLayer(map: mapViewModel.map),
                                      let septicPermitTable = mapViewModel.getSepticPermitTable(map: mapViewModel.map),
                                      let septicFeatureTable = septicLayer.featureTable as? ServiceFeatureTable,
                                      let propertyGeometry = property.geometry
                                else {
                                    return
                                }
                                
                                // Await querySepticPoint call and handle the result
                                
                                // Use await to handle the async call
                                
                                await propertyInfoVM.querySepticPoint(for: septicFeatureTable, geometry: propertyGeometry) { septicFeatures in
                                    for feature in septicFeatures {
                                        // Safely unwrap the permit number using optional binding
                                        if let permitNum = feature.attributes["PERMIT_NUMBER"] as? String {
                                            // Call querySepticPermit with a completion handler
                                            Task {
                                                await propertyInfoVM.querySepticPermit(for: septicPermitTable, permitNum: permitNum) { permits in
                                                    var permitId = ""
                                                    for permit in permits {
                                                        if let id = permit.attributes["PMPERMITID"] as? String {
                                                            permitId = id
                                                            // Process permitId if needed
                                                        }
                                                    }
                                                    
                                                    // Handle the permitId or any other logic here
                                                    if !permitId.isEmpty {
                                                        print("Found permit ID: \(permitId)")
                                                        propertyInfoVM.septicPermitId = permitId
                                                    } else {
                                                        print("No permit ID found for permit number: \(permitNum)")
                                                        propertyInfoVM.septicPermitId = nil
                                                    }
                                                }
                                            }
                                        } else {
                                            // Handle the case where permitNum is nil
                                            print("Permit number is missing or invalid for feature: \(feature)")
                                        }
                                    }
                                }

                            }
                        }
                    }
                }

            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("Background"))
        .navigationTitle("Property")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let siteAddress = feature.feature.attributes["SITE_ADDRESS"] as? String,
                let pinNum = feature.feature.attributes["PIN_NUM"] as? String,
                let url = URL(string: "https://maps.raleighnc.gov/imaps-mobile?address=\(siteAddress)&pin=\(pinNum)") {
                let subject = Text("View \(siteAddress) in iMAPS")
                let message = Text("View \(siteAddress) in iMAPS")
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url, subject: subject, message: message, preview: SharePreview("View \(siteAddress) in iMAPS", image: Image("imaps"))) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    Button(action: {
                        // Action to perform when the button is tapped
                        self.panelVM.fullScreen.toggle()
                        // Add your custom action here, for example, navigation or triggering some state change.
                    }) {
                        Image(systemName: self.panelVM.fullScreen == true ? "arrow.down.right.and.arrow.up.left.rectangle" : "arrow.down.backward.and.arrow.up.forward.rectangle")
                            .foregroundColor(.blue) // Optional: Customize the color
                    }
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
