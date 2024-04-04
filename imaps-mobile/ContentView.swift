import SwiftUI
import ArcGIS
import ArcGISToolkit
import CoreLocation
import SwiftUIIntrospect

struct ContentView: View {
    @State private var popupDetent: FloatingPanelDetent = .full
    @StateObject var panelVM = PanelViewModel(isPresented: true)
    private let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    @State private var failedToStart = false
    @State private var locationEnabled = false
    @State private var showPopup = false
    @State private var identifyScreenPoint: CGPoint?
    @State private var popup: Popup?
    @State private var identifyResultCount = 0
    @State private var identifyResultIndex = 0
    @State private var identifyResults:[IdentifyLayerResult]? = []
    @State private var longPressScreenPoint: CGPoint?
    @State private var attributionBarHeight: CGFloat = 0
    @State private var isKeyboardVisible = false
    @State var basemapVM = BasemapViewModel(selected: .Maps, center: Point(x:0,y:0))
    @State var isPortrait: Bool = UIDevice.current.orientation.isPortrait
    @State var appSize: CGSize = CGSize(width: 0, height: 0)
    @StateObject private var mapViewModel = MapViewModel(
        map: Map (
            item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
        ),
        graphics: GraphicsOverlay(graphics: []),
        viewpoint: Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
            
    )

    private var initialViewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .topTrailing) {
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
                        identifyScreenPoint = screenPoint
                    }
                    .onLongPressGesture {screenPoint, _ in
                        longPressScreenPoint = screenPoint
                    }
                    .locationDisplay(locationDisplay)
                    .onAttributionBarHeightChanged {
                        attributionBarHeight = $0
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    .alert("Location display failed to start", isPresented: $failedToStart) {}
                    .task(id: identifyScreenPoint) {
                        guard let identifyScreenPoint = identifyScreenPoint,
                              
                                let identifyResult = try? await proxy.identifyLayers(
                                    screenPoint: identifyScreenPoint,
                                    tolerance: 10,
                                    returnPopupsOnly: true
                                )
                        else { return }
                        self.identifyResults = identifyResult
                        
                        self.identifyResultCount = identifyResult.filter{result in result.layerContent.name != "Property"}.count
                        self.popup = identifyResult.first(where: {$0.layerContent.name != "Property"})?.popups.first
                        self.showPopup = self.popup != nil
                    }
                    .task (id: longPressScreenPoint) {
                        guard let longPressScreenPoint else { return }
                        do {
                            let identifyResult = try await proxy.identifyLayers(
                                screenPoint: longPressScreenPoint,
                                tolerance: 10,
                                returnPopupsOnly: false
                            )
                            let result = identifyResult.first(where: {$0.layerContent.name == "Property"})
                            if result != nil {
                                if result!.geoElements.count > 0 {
                                    self.panelVM.selectedPinNum = result?.geoElements.first?.attributes["PIN_NUM"] as! String
                                    
                                    let encoder = JSONEncoder()
                                    guard let address = result?.geoElements.first?.attributes["SITE_ADDRESS"] as? String else { return }
                                    let history = updateStorageHistory(field: "SITE_ADDRESS", value: address)
                                    if let encoded = try? encoder.encode(history) {
                                        UserDefaults.standard.set(encoded, forKey: "searchHistory")
                                    }
                                    self.panelVM.selectedPanel = .search
                                    self.panelVM.isPresented = true
                                }
                                if UIDevice.current.userInterfaceIdiom != .pad {
                                    self.showPopup = false
                                }
                            }
                        } catch {
                            
                        }
                        
                    }
                    .onAppear {
                        self.appSize = geo.size
                        self.isPortrait = self.appSize.height > self.appSize.width
                        self.mapViewModel.proxy = proxy
                        let center: String? = UserDefaults.standard.string(forKey: "center")
                        let scale: Double = UserDefaults.standard.double(forKey: "scale")
                        if (center != nil) {
                            mapViewModel.viewpoint = try? Viewpoint(center:  Geometry.fromJSON(center!) as! Point, scale: scale)
                        }
                        else {
                            mapViewModel.viewpoint = Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
                        }
                        basemapVM.center = (mapViewModel.viewpoint?.targetGeometry.extent.center)!
                    }
                }
                .onChange(of: geo.size) { _ in
                    self.appSize = geo.size
                    self.isPortrait = self.appSize.height > self.appSize.width
                    print(self.isPortrait)
                    
                }
                .alert("Location display failed to start", isPresented: $failedToStart) {}

            }
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    backgroundColor: Color("Background"),
                    selectedDetent: $panelVM.selectedDetent,
                    horizontalAlignment: .leading,
                    isPresented: $panelVM.isPresented
                ) {
                    GeometryReader { geo in
                        ZStack {
                            switch self.panelVM.selectedPanel {
                            case .search:
                                SearchView()
                                    .environmentObject(mapViewModel)
                                    .environmentObject(panelVM)
                            case .layers:
                                LayersView(mapViewModel: mapViewModel)
                                    .environmentObject(mapViewModel)
                                    .environmentObject(panelVM)
                            case .basemap:
                                BasemapView(basemapVM: self.basemapVM)
                                    .environmentObject(mapViewModel)
                                    .environmentObject(panelVM)
                            case .property:
                                PropertyView(viewModel: ViewModel(text: self.panelVM.selectedPinNum), group: SearchGroup(field: "PIN_NUM", alias: "PIN", features: []), source: .map)
                                    .environmentObject(mapViewModel)
                                    .environmentObject(panelVM)
                            }
                            
                        }
                        .background(Color("Background"))
                        .onChange(of: geo.size) { _ in
                            self.panelVM.size = geo.size
  
                            
                        }
                    }
                    }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    backgroundColor: Color("Background"),
                               selectedDetent: $popupDetent,
                               horizontalAlignment: .trailing,
                               isPresented: $showPopup
                ) { [popup] in
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
                                    
                                    self.popup = identifyResults?[identifyResultIndex].popups.first
                                } label: {
                                    Image(systemName: "chevron.right.circle.fill")
                                }
                            }
                        }
                        PopupView(popup: popup!, isPresented: $showPopup).showCloseButton(true)
                            .padding(.all)
                        
                    }.padding(.all)
                }
                
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .overlay(alignment: .topTrailing) {
                    if (!self.panelVM.isPresented ||  ( self.panelVM.size.height < 500) &&  self.isKeyboardVisible == false) || UIDevice.current.userInterfaceIdiom == .pad   {
                        ButtonBarView()
                            .environmentObject(panelVM)

                    }
                }
                
                .overlay(alignment: UIDevice.current.userInterfaceIdiom == .pad  ? .bottomTrailing : self.isPortrait == true ? .topLeading : .bottomTrailing) {
                    if (!self.panelVM.isPresented ||  ( self.panelVM.size.height < 500) &&  self.isKeyboardVisible == false) || UIDevice.current.userInterfaceIdiom == .pad  {
                        
                        LocationButtonView(locationEnabled: self.locationEnabled, failedToStart: self.failedToStart,
                                           locationDisplay: locationDisplay
                        )
                            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad  ? 30 : self.isPortrait ? 10 : 30).padding(.horizontal, 10)
 
                    }
                }
            }
            

        
            .onReceive(panelVM.$selectedDetent) { _ in
                if (self.isKeyboardVisible && self.panelVM.selectedDetent != .full) {
                    self.panelVM.selectedDetent = .full
                }
            }

            .onReceive(panelVM.$isPresented) { _ in
                if !panelVM.isPresented {
                    var keyWindow: UIWindow? {
                        return UIApplication.shared.connectedScenes
                            .filter { $0.activationState == .foregroundActive }
                            .first(where: { $0 is UIWindowScene })
                            .flatMap({ $0 as? UIWindowScene })?.windows
                            .first(where: \.isKeyWindow)
                    }
                    keyWindow?.endEditing(true)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                self.isKeyboardVisible = true
                self.panelVM.selectedDetent = .full
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                self.isKeyboardVisible = false
            }
            .onAppear {
                self.panelVM.isPresented = UIDevice.current.userInterfaceIdiom == .pad
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
