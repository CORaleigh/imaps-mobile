import SwiftUI
import ArcGIS
import ArcGISToolkit
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var panelVM = PanelViewModel(isPresented: false)
    @StateObject var popupVM = PopupViewModel(isPresented: false)
    @State var basemapVM = BasemapViewModel(selected: .Maps, center: Point(x:0,y:0))
    @State private var isKeyboardVisible = false
    @StateObject  var mapViewModel = MapViewModel(
        map: Map (
            item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
        )
    )
    
    var body: some View {
        ZStack (alignment: .topTrailing) {
            if #available(iOS 16.4, *), UIDevice.current.userInterfaceIdiom == .phone {
                WebMapView(mapViewModel: mapViewModel, popupVM: popupVM, panelVM: panelVM, basemapVM: basemapVM)
                    
                    .sheet(isPresented: self.$panelVM.isPresented) {
                        PanelContentView(mapViewModel: self.mapViewModel, panelVM: self.panelVM, basemapVM: self.basemapVM)
                            .presentationDetents([.medium, .large, .bar], selection: self.$panelVM.selectedDetent)
                            .presentationBackgroundInteraction(.enabled)
                            .presentationContentInteraction(.scrolls)
                    }
                    .sheet(isPresented: self.$popupVM.isPresented) {
                        PopupContentView(popupVM: popupVM)
                        
                            .presentationDetents([.medium, .large, .bar], selection: self.$popupVM.selectedDetent)
                            .presentationBackgroundInteraction(.enabled)
                            .presentationContentInteraction(.scrolls)
                    }
            
            } else {
                WebMapView(mapViewModel: mapViewModel, popupVM: popupVM, panelVM: panelVM, basemapVM: basemapVM)
                    .floatingPanel(
                        attributionBarHeight: mapViewModel.attributionBarHeight,
                        backgroundColor: Color("Background"),
                        selectedDetent: $panelVM.selectedFloatingPanelDetent,
                        horizontalAlignment: .leading,
                        isPresented: $panelVM.isPresented
                        //UIDevice.current.userInterfaceIdiom == .pad ? $panelVM.isPresented :  .constant(false)
                    ) {
                        PanelContentView(mapViewModel: self.mapViewModel, panelVM: self.panelVM, basemapVM: self.basemapVM)
                        
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .floatingPanel(
                        attributionBarHeight: mapViewModel.attributionBarHeight,
                        selectedDetent: $popupVM.selectedFloatingPanelDetent,
                        horizontalAlignment: .trailing,
                        isPresented: self.$popupVM.isPresented
                        //UIDevice.current.userInterfaceIdiom == .pad ? self.$popupVM.isPresented :  .constant(false)
                    ) { [popupVM] in
                        PopupContentView(popupVM: popupVM)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
        }
        .onReceive(panelVM.$selectedDetent) { _ in
            if (self.isKeyboardVisible && self.panelVM.selectedFloatingPanelDetent != .full) {
                self.panelVM.selectedFloatingPanelDetent = .full
            }
        }
        .onReceive(panelVM.$isPresented) { isPresented in
            print(isPresented)
            if !isPresented {
                var keyWindow: UIWindow? {
                    return UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first(where: { $0 is UIWindowScene })
                        .flatMap({ $0 as? UIWindowScene })?.windows
                        .first(where: \.isKeyWindow)
                }
                keyWindow?.endEditing(true)
            } else {
                self.popupVM.isPresented = false
            }
        }
        .onReceive(popupVM.$isPresented) { _ in
            if popupVM.isPresented {
                self.panelVM.isPresented = false
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            self.isKeyboardVisible = true
            self.panelVM.selectedFloatingPanelDetent = .full
            self.panelVM.selectedDetent = .large
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            self.isKeyboardVisible = false
        }
        .onAppear {
            self.panelVM.isPresented = UIDevice.current.userInterfaceIdiom == .pad
        }
        .onChange(of: networkMonitor.isConnected) { connection in
            if connection {
                if mapViewModel.map.loadStatus != .loaded {
                    Task {
                        try? await mapViewModel.map.retryLoad()
                        
                    }
                } else {
                    mapViewModel.map = mapViewModel.map.clone()
                    Task {
                        try? await mapViewModel.map.load()
                        mapViewModel.viewpoint = self.mapViewModel.setViewpoint()
                    }
                }
            }
        }
        .alert(
            "Network connection seems to be offline.",
            isPresented: .constant(networkMonitor.isConnected == false)
        ) {}
        
 
            .onOpenURL{ url in
                Task {
                    
                    
                    try await Task.sleep(nanoseconds: 500_000_000)
                    switch url.host {
                    case "pin":
                        if url.query != nil {
                            try await self.mapViewModel.map.load()
                            self.panelVM.selectedPinNum = url.query ?? ""
                            self.panelVM.isPresented = true
                            
                        }
                    default:
                        break
                    }
                }
            }
    }
}
extension PresentationDetent {
    static let bar = Self.custom(BarDetent.self)
    
}
private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

