//
//  ContentView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/24/23.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit
import CoreLocation

enum SelectedPanel {
case search, layers, basemap, property
}

class PanelViewModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var selectedDetent: FloatingPanelDetent = .full
    init(isPresented: Bool) {
        self.isPresented = isPresented
    }
    func dismiss() {
        self.isPresented = false
    }
}

struct ContentView: View {
    @State private var popupDetent: FloatingPanelDetent = .full

    @StateObject var panelVM = PanelViewModel(isPresented: true)
    @State var selectedPanel = SelectedPanel.search

    @State var selectedPinNum: String = ""
    private let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    @State private var failedToStart = false
    @State private var locationEnabled = false
    
    @State private var showPopup = false
    @State private var identifyScreenPoint: CGPoint?
    @State private var popup: Popup?
    @State private var identifyResultCount = 0
    @State private var identifyResultIndex = 0
    @State private var identifyResults:[IdentifyLayerResult]? = []

    @State private var isKeyboardVisible = false

    
    @StateObject private var dataModel = MapDataModel(
        map: Map (
            item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
        ),
        graphics: GraphicsOverlay(graphics: []),
        viewpoint: Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
    )

    private var initialViewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
    var body: some View {
        NavigationView {
            MapViewReader { proxy in
                MapView(
                    map: dataModel.map,
                    viewpoint: dataModel.viewpoint,
                    graphicsOverlays: [dataModel.graphics]
                )
                .onViewpointChanged(kind: .centerAndScale) { viewpoint in
                    UserDefaults.standard.set(viewpoint.targetScale, forKey: "scale")
                    UserDefaults.standard.set(viewpoint.targetGeometry.toJSON(), forKey: "center")
                    
                }
                .onSingleTapGesture {screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .onLongPressGesture(perform: { viewPoint, mapPoint in
                    Task {
                        let screenpoint: CGPoint? = viewPoint
                        guard let screenpoint = screenpoint,
                              let identifyResult = await Result(awaiting: {
                                  try await proxy.identifyLayers(
                                    screenPoint: screenpoint,
                                    tolerance: 10,
                                    returnPopupsOnly: false
                                  )
                              })
                            .cancellationToNil()
                        else {
                            return
                        }
                        let result = try? identifyResult.get().first(where: {$0.layerContent.name == "Property"})
                        if result != nil {
                            if result!.geoElements.count > 0 {
                                self.selectedPinNum = result?.geoElements.first?.attributes["PIN_NUM"] as! String

                                let encoder = JSONEncoder()
                                let history = updateStorageHistory(field: "SITE_ADDRESS", value: result?.geoElements.first?.attributes["SITE_ADDRESS"] as! String)
                                if let encoded = try? encoder.encode(history) {
                                    UserDefaults.standard.set(encoded, forKey: "searchHistory")
                                }
                        

                                self.selectedPanel = .property
                                self.panelVM.isPresented = true
//                                self.isPresented = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    self.isPresented = true
//                                }
                            }
                        }
                    }
                })
                .locationDisplay(locationDisplay)
                .alert("Location display failed to start", isPresented: $failedToStart) {}
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint = identifyScreenPoint,
                          let identifyResult = await Result(awaiting: {
                              try await proxy.identifyLayers(
                                screenPoint: identifyScreenPoint,
                                tolerance: 10,
                                returnPopupsOnly: true
                              )
                          })
                        .cancellationToNil()
                    else {
                        return
                    }
                    self.identifyScreenPoint = nil
                    self.identifyResults = try! identifyResult.get()
                    self.identifyResultCount = try! identifyResult.get().count
                    self.popup = try? identifyResult.get().first?.popups.first
                    self.showPopup = self.popup != nil
                    self.panelVM.isPresented = false
                }
                .onAppear {
                    self.dataModel.proxy = proxy
                    let center: String? = UserDefaults.standard.string(forKey: "center")
                    let scale: Double = UserDefaults.standard.double(forKey: "scale")
                    if (center != nil) {
                        dataModel.viewpoint = try? Viewpoint(center:  Geometry.fromJSON(center!) as! Point, scale: scale)
                    }
                    else {
                        dataModel.viewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
                    }
                }

            }
            
            .floatingPanel(selectedDetent: $popupDetent,
                           horizontalAlignment: .trailing,
                           isPresented: $showPopup
            ) {
                VStack {
                    if (identifyResultCount > 1) {
                        HStack{
                            Button {
                                if (identifyResultIndex == 0) {
                                    identifyResultIndex = identifyResultCount - 1
                                } else {
                                    identifyResultIndex -= 1
                                }
                                self.popup = identifyResults![identifyResultIndex].popups.first
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                            }
                            Text(String(identifyResultIndex+1)+" of "+String(identifyResultCount))
                            Button {
                                if (identifyResultIndex == identifyResultCount - 1) {
                                    identifyResultIndex = 0
                                } else {
                                    identifyResultIndex += 1
                                }
                                self.popup = identifyResults![identifyResultIndex].popups.first
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                            }
                        }
                    }
                    if let popup = popup {
                        PopupView(popup: popup, isPresented: $showPopup).showCloseButton(true)
                    }
                }
            }
            .floatingPanel(selectedDetent: $panelVM.selectedDetent, horizontalAlignment: .leading, isPresented: $panelVM.isPresented
            
            ) {
                VStack {
                    if selectedPanel == .search {
                        SearchView()
                        .environmentObject(dataModel)
                        .environmentObject(panelVM)


                    }
                    if selectedPanel == .layers {
                        LayersView()
                            .environmentObject(dataModel)
                            .environmentObject(panelVM)

                    }
                    if selectedPanel == .basemap {
                        BasemapView()
                            .environmentObject(dataModel)
                            .environmentObject(panelVM)

                        
                    }
                    if selectedPanel == .property {
                        let viewModel: ViewModel = ViewModel(text: self.selectedPinNum)
                        PropertyView(viewModel: viewModel, group: SearchGroup(field: "PIN_NUM", alias: "PIN", features: []), source: .map)
                            .environmentObject(dataModel)
                            .environmentObject(panelVM)

                    }
                }

            }
            
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button( action: {
                        if selectedPanel == .search {
                            panelVM.isPresented.toggle()
                        } else {
                            panelVM.isPresented = true
                        }
                        selectedPanel = .search
                    }, label: {
                        Image(systemName: "magnifyingglass")

                    })
                    Button(action: {
                        if selectedPanel == .layers {
                            panelVM.isPresented.toggle()
                        } else {
                            panelVM.isPresented = true
                        }
                        selectedPanel = .layers
                    }, label: {
                        Image(systemName: "square.3.layers.3d")

                    })
                    Button(action: {
                        if selectedPanel == .basemap {
                            panelVM.isPresented.toggle()
                        } else {
                            panelVM.isPresented = true
                        }
                        selectedPanel = .basemap
                    }, label: {
                        Image(systemName: "map")

                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        locationEnabled.toggle()
                        Task {
                            let locationManager = CLLocationManager()
                            if locationManager.authorizationStatus == .notDetermined {
                                locationManager.requestWhenInUseAuthorization()
                            }

                            do {
                                if (locationEnabled) {
                                    try await locationDisplay.dataSource.start()

                                    locationDisplay.initialZoomScale = 40_000
                                    locationDisplay.autoPanMode = .recenter
                                } else {
                                    await  locationDisplay.dataSource.stop()
                                }


                            } catch {

                                self.failedToStart = true

                            }
                        }
                    }, label: {
                        Image(systemName: "location.circle")

                    })
                }
            }
            
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.panelVM.isPresented = UIDevice.current.userInterfaceIdiom == .pad
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            self.panelVM.selectedDetent = .full
            self.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            self.isKeyboardVisible = false
        }
        .onReceive(panelVM.$selectedDetent) { _ in
            if (self.isKeyboardVisible && self.panelVM.selectedDetent != .full) {
                self.panelVM.selectedDetent = .full
            }
        }
        .onReceive(panelVM.$isPresented) { _ in
            if !panelVM.isPresented {
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
            }
            
        }
    }

    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
