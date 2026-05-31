import SwiftUI
import ArcGISToolkit
import ArcGIS

@MainActor
class PopupViewModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var identifyScreenPoint: CGPoint?
    @Published var popup: Popup?
    @Published var identifyResults:[IdentifyLayerResult] = []
    @Published var selectedFloatingPanelDetent: FloatingPanelDetent = UIDevice.current.userInterfaceIdiom == .pad ? .full : .half
    @Published var selectedDetent: PresentationDetent = .medium
    @Published var popupCount = 0
    @Published var geoElement: GeoElement?
    @Published var layer: FeatureLayer?
    @Published var layerName: String = ""

    init(isPresented: Bool) {
        self.isPresented = isPresented
    }
    func dismiss() {
        self.isPresented = false
    }
}
struct IdentifyLayerResultWrapper: Hashable, Equatable {
    let result: IdentifyLayerResult
    
    static func == (lhs: IdentifyLayerResultWrapper, rhs: IdentifyLayerResultWrapper) -> Bool {
        guard lhs.result.layerContent === rhs.result.layerContent else { return false }
        let lhsAttributes = lhs.result.geoElements.map { hashedAttributes($0.attributes) }
        let rhsAttributes = rhs.result.geoElements.map { hashedAttributes($0.attributes) }
        return lhsAttributes == rhsAttributes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(result.layerContent))
        let attributesHashes = result.geoElements.map { IdentifyLayerResultWrapper.hashedAttributes($0.attributes) }
        hasher.combine(attributesHashes)
    }
    
    private static func hashedAttributes(_ attributes: [String: Any]) -> Int {
        return attributes.map { ($0.key.hashValue ^ ($0.value as? Int ?? 0)) }.reduce(0, ^)
    }
}


