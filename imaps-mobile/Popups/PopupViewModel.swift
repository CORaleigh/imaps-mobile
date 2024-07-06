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

extension IdentifyLayerResult: Hashable {
    public static func == (lhs: IdentifyLayerResult, rhs: IdentifyLayerResult) -> Bool {
        // Check equality based on properties you consider relevant
        guard lhs.layerContent === rhs.layerContent else { return false }

        // Compare geoElements based on their attributes
        let lhsAttributes = lhs.geoElements.map { hashedAttributes($0.attributes) }
        let rhsAttributes = rhs.geoElements.map { hashedAttributes($0.attributes) }

        return lhsAttributes == rhsAttributes
    }

    public func hash(into hasher: inout Hasher) {
        // Combine hash values of relevant properties
        hasher.combine(ObjectIdentifier(layerContent))

        // Hash attributes of geoElements
        let attributesHashes = geoElements.map { IdentifyLayerResult.hashedAttributes($0.attributes) }
        hasher.combine(attributesHashes)
    }

    private static func hashedAttributes(_ attributes: [String: Any]) -> Int {
        // Hash the attributes dictionary manually
        // You might need to implement custom logic based on your specific requirements
        // For example, you can concatenate the hash values of all key-value pairs
        return attributes.map { ($0.key.hashValue ^ ($0.value as? Int ?? 0)) }.reduce(0, ^)
    }
}


