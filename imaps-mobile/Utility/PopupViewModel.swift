import SwiftUI
import ArcGISToolkit
import ArcGIS

@MainActor
class PopupViewModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var identifyScreenPoint: CGPoint?
    @Published var popup: Popup?
    @Published var identifyResultCount = 0
    @Published var identifyResultIndex = 0
    @Published var identifyResults:[IdentifyLayerResult]? = []
    @Published var selectedFloatingPanelDetent: FloatingPanelDetent = .full
    @Published var selectedDetent: PresentationDetent = .large
    
    init(isPresented: Bool) {
        self.isPresented = isPresented
    }
    func dismiss() {
        self.isPresented = false
    }
}
