//
//  ContentView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit
import CoreLocation
class SharedData: ObservableObject {
    @Published var map: Map = Map()

    @Published var viewpoint: Viewpoint? = nil
    @Published var graphics = GraphicsOverlay(graphics: [])
    @Published var table: FeatureTable? = nil
    @Published var layersLoaded: Bool = false
    @Published var longPressResults: [Feature]?
    @Published var proxy: MapViewProxy? = nil
}

struct ContentView: View {
    @ObservedObject var shared = SharedData()
    
    @State private var showingSearch = false
    @State private var showingLayers = false
    @State private var showingBasemaps = false
    @State private var showingInfo = false

    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    @State private var showPopup = false
    @State private var identifyScreenPoint: CGPoint?
    @State private var popup: Popup?
    @State private var identifyResultCount = 0
    @State private var identifyResultIndex = 0
    @State private var identifyResults:[IdentifyLayerResult]? = []
    private let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    @State private var failedToStart = false
    @State private var locationEnabled = false
    @State private var sheetDetent: PresentationDetent = .medium
    

    var body: some View {
        
        VStack {
            MapViewReader { proxy in
                MapView(
                    map: shared.map,
                    viewpoint: shared.viewpoint,
                    graphicsOverlays: [shared.graphics]
                )
                .onViewpointChanged(kind: .centerAndScale) { viewpoint in
                    UserDefaults.standard.set(viewpoint.targetScale, forKey: "scale")
                    UserDefaults.standard.set(viewpoint.targetGeometry.toJSON(), forKey: "center")
                    
                }
                .onSingleTapGesture {screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }

                .onLongPressGesture(perform: { viewPoint, mapPoint in
                    self.showingInfo = false
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
                        await getCondos(result: result, table: shared.table as! ServiceFeatureTable, completion: { condos in

                            shared.longPressResults = condos
                            self.showingBasemaps = false
                            self.showingLayers = false
                            self.showPopup = false
                            self.showingSearch = false
                            self.showingInfo = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.showingInfo = true
                            }
                        })
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
                }
                .floatingPanel(selectedDetent: $floatingPanelDetent,
                               horizontalAlignment: .leading,
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
                .onAppear {
                    shared.map = Map (
                        item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
                    )
                    shared.proxy = proxy
                    Task {
                        let center: String? = UserDefaults.standard.string(forKey: "center")
                        let scale: Double = UserDefaults.standard.double(forKey: "scale")
                        if (center != nil) {
                            shared.viewpoint = try? Viewpoint(center:  Geometry.fromJSON(center!) as! Point, scale: scale)
                        }
                        else {
                            shared.viewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
                        }
                        shared.layersLoaded = await setLayerVisibility(map: shared.map, layersLoaded: shared.layersLoaded)
                        
                    }

                }
            }

        }
        .sheet(isPresented: $showingInfo) {
            if (shared.longPressResults!.count == 1) {
                if #available(iOS 16.4, *) {
                    
                    NavigationView {
                        InfoView(feature: shared.longPressResults?.first, fromSearch: false)
                    }
                    .navigationTitle("Property")
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(shared)
                    .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationContentInteraction(.scrolls)
                } else {
                    NavigationView {
                        InfoView(feature: shared.longPressResults?.first, fromSearch: false)
                    }
                    .navigationTitle("Property")
                    .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(shared)
                }
            } else if (shared.longPressResults!.count > 1) {
                if #available(iOS 16.4, *) {
                    
                    NavigationView {
                        PropertyListView(features: shared.longPressResults!, fromSearch: false)
                    }
                    .navigationTitle("Property List")
                    .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                    .navigationBarTitleDisplayMode(.inline)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationContentInteraction(.scrolls)
                    
                } else {
                    NavigationView {
                        PropertyListView(features: shared.longPressResults!, fromSearch: false)
                    }
                    .navigationTitle("Property List")
                    .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                    .navigationBarTitleDisplayMode(.inline)
                    
                }

            }

        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    showingSearch.toggle()
                    //sheetDetent = .large
                }, label: {
                    Image(systemName: "magnifyingglass")
                })
                .sheet(isPresented: $showingSearch) {
                    if #available(iOS 16.4, *) {
                        SearchView()
                            .environmentObject(shared)
                            .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                            .presentationContentInteraction(.scrolls)
                    } else {
                        SearchView()
                            .environmentObject(shared)
                            .presentationDetents([.medium, .large, .height(80.0)], selection: $sheetDetent)
                    }

                }
                Spacer()

                Button(action: {
                    showingLayers.toggle()
                    sheetDetent = .large

                }, label: {
                    Image(systemName: "square.3.layers.3d")

                })
                .sheet(isPresented: $showingLayers) {
                    if #available(iOS 16.4, *) {
                        
                        NavigationView {
                            LayersView()
                                .environmentObject(shared)
                                                    
                        }
                        .navigationViewStyle(.stack)
                        .presentationDetents([.medium, .large, .height(40.0)], selection: $sheetDetent)
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        .presentationContentInteraction(.scrolls)

                    } else {
                        NavigationView {
                            LayersView()
                                .environmentObject(shared)

                            

                            
                        }
                        .navigationViewStyle(.stack)
                        .presentationDetents([.medium, .large, .height(40.0)], selection: $sheetDetent)
                        
                    }

  
                }
                Spacer()

                Button(action: {
                    showingBasemaps.toggle()
                    sheetDetent = .large

                }, label: {
                    Image(systemName: "map")
                })
                .sheet(isPresented: $showingBasemaps) {
                    if #available(iOS 16.4, *) {
                    NavigationView {
                        BasemapView()
                            .environmentObject(shared)
                            .navigationTitle("Base Maps")
                            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                    }
                    .navigationViewStyle(.stack)
                    .presentationDetents([.medium, .large, .height(40.0)], selection: $sheetDetent)

                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        .presentationContentInteraction(.scrolls)


                    } else {
                        NavigationView {
                            BasemapView()
                                .environmentObject(shared)
                                .navigationTitle("Base Maps")
                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                        }
                        .navigationViewStyle(.stack)
                        .presentationDetents([.medium, .large, .height(40.0)], selection: $sheetDetent)
                    }
                }
                Spacer()

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
        .environmentObject(shared)
        .onAppear {
            Task {
                
                try await shared.map.load()
                for table in shared.map.tables {
                    do {
                        try await table.load()
                        if table.tableName.contains("Condos") {
                            shared.table = table
                        }
                    }
                }

            }
        }
    }
    
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
