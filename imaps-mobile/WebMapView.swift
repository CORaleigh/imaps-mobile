import SwiftUI
import ArcGIS

struct WebMapView: View {
    @StateObject  var mapViewModel:MapViewModel
    @StateObject  var popupVM:PopupViewModel
    @StateObject  var panelVM:PanelViewModel
    @StateObject  var basemapVM:BasemapViewModel
    @State private var isPortrait: Bool = UIDevice.current.orientation.isPortrait

    var body: some View {
        GeometryReader { geo in
            MapViewReader { proxy in
                MapView(
                    map: mapViewModel.map,
                    viewpoint: mapViewModel.viewpoint,
                    graphicsOverlays: [mapViewModel.graphics]
                )
                .magnifierDisabled(true)
                .onViewpointChanged(kind: .centerAndScale) { viewpoint in
                    UserDefaults.standard.set(viewpoint.targetScale, forKey: "scale")
                    UserDefaults.standard.set(viewpoint.targetGeometry.toJSON(), forKey: "center")
                    self.basemapVM.objectWillChange.send()
                    self.basemapVM.center = viewpoint.targetGeometry.extent.center
                }
                .onSingleTapGesture {screenPoint, _ in
                    self.popupVM.identifyScreenPoint = screenPoint
                }
                .onLongPressGesture {screenPoint, _ in
                    mapViewModel.longPressScreenPoint = screenPoint
                }
                .locationDisplay(mapViewModel.locationDisplay)
                .onAttributionBarHeightChanged {
                    mapViewModel.attributionBarHeight = $0
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                .alert("Location display failed to start", isPresented: $mapViewModel.failedToStart) {}
                .task(id: self.popupVM.identifyScreenPoint) {
                    guard let identifyScreenPoint = self.popupVM.identifyScreenPoint,
                          
                            var identifyResult = try? await proxy.identifyLayers(
                                screenPoint: identifyScreenPoint,
                                tolerance: 10,
                                returnPopupsOnly: false,
                                maximumResultsPerLayer: 50
                            )
                    else { return }
                    self.popupVM.popupCount = 0
                    self.popupVM.identifyResults = []
                    identifyResult = identifyResult.filter{result in result.layerContent.name != "Property" && result.layerContent.name != "Raleigh Sewer"}
                    identifyResult.forEach { result in
                        if (result.sublayerResults.count > 0) {
                            result.sublayerResults.forEach { sublayerResult in
                                self.popupVM.popupCount += sublayerResult.popups.count

                                self.popupVM.identifyResults.append(sublayerResult)
                            }
                        } else {
                            self.popupVM.popupCount += result.popups.count
                            self.popupVM.identifyResults.append(result)

                        }
                    }
                    self.popupVM.popup = nil
                    
                    if self.popupVM.popupCount == 1 {
                        if let result = identifyResult.first(where: {$0.layerContent.name != "Property" && $0.layerContent.name != "Raleigh Sewer" && $0.popups.count > 0}),
                           let popup = result.popups.first,
                           let geoElement = result.geoElements.first,
                           let layer = result.layerContent as? FeatureLayer {
                            self.popupVM.popup = popup
                            self.popupVM.geoElement = geoElement
                            self.popupVM.layer = layer
                            self.popupVM.layerName = result.layerContent.name
                            
                        }
//                        self.popupVM.popup = identifyResult.first(where: {$0.layerContent.name != "Property" && $0.layerContent.name != "Raleigh Sewer" && $0.popups.count > 0})?.popups.first
                        
                    }

                    self.popupVM.isPresented = popupVM.popupCount > 0//self.popupVM.identifyResultCount > 0
                }
                .task(id: mapViewModel.longPressScreenPoint) {
                    guard let longPressScreenPoint = mapViewModel.longPressScreenPoint else { return }
                    do {
                        let identifyResult = try await proxy.identifyLayers(
                            screenPoint: longPressScreenPoint,
                            tolerance: 10,
                            returnPopupsOnly: false
                        )
                        guard let result = identifyResult.first(where: { $0.layerContent.name == "Property" }) else { return }

                        if result.geoElements.count > 0 {
                            self.panelVM.selectedPinNum = result.geoElements.first?.attributes["PIN_NUM"] as! String
                            let encoder = JSONEncoder()
                            guard let address = result.geoElements.first?.attributes["SITE_ADDRESS"] as? String else { return }
                            let history = updateStorageHistory(field: "SITE_ADDRESS", value: address)
                            if let encoded = try? encoder.encode(history) {
                                UserDefaults.standard.set(encoded, forKey: "searchHistory")
                            }
                            self.panelVM.selectedPanel = .search
                            self.panelVM.isPresented = true
                        }

                    } catch {
                        print("Error identifying layers: \(error)")
                        // Handle the error as needed
                    }
                }

                .overlay(alignment: .topTrailing) {
                    ButtonBarView(panelVM: panelVM)
                }
                .overlay(alignment: UIDevice.current.userInterfaceIdiom == .pad  ? .bottomTrailing : self.isPortrait == true ? .topLeading : .bottomTrailing) {
                    LocationButtonView(locationEnabled: self.mapViewModel.locationEnabled, failedToStart: self.mapViewModel.failedToStart, showAlert: false,
                                       locationDisplay: self.mapViewModel.locationDisplay
                    )
                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad  ? 30 : self.isPortrait ? 10 : 30).padding(.horizontal, 10)
                }
                .onAppear {
                    self.isPortrait = geo.size.height > geo.size.width
                    self.mapViewModel.proxy = proxy
                    let center: String? = UserDefaults.standard.string(forKey: "center")
                    let scale: Double = UserDefaults.standard.double(forKey: "scale")
                    if (center != nil) {
                        do {
                            if let center = center {
                                mapViewModel.viewpoint = try Viewpoint(center:  Geometry.fromJSON(center) as! Point, scale: scale)
                            }
                        } catch {
                            print("Error initializing Viewpoint: \(error)")
                        }
                    }
                    else {
                        mapViewModel.viewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
                    }
                    if let viewpoint = mapViewModel.viewpoint {
                        basemapVM.center = viewpoint.targetGeometry.extent.center
                    }

                }
                .onChange(of: geo.size) { _ in
                    self.isPortrait = geo.size.height > geo.size.width
                }
            }
        }
    }
}

#Preview {
    WebMapView(mapViewModel: MapViewModel(), popupVM: PopupViewModel(isPresented: false), panelVM: PanelViewModel(isPresented: false), basemapVM: BasemapViewModel(selected: .Maps, center: Point(latitude: 0, longitude: 0)))
}
