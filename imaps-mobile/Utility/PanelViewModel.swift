import SwiftUI
import ArcGISToolkit

@MainActor
class PanelViewModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var selectedFloatingPanelDetent: FloatingPanelDetent = .full
    @Published var selectedDetent: PresentationDetent = .medium
    @Published var selectedPanel: SelectedPanel = SelectedPanel.search
    @Published var selectedPinNum: String = ""
    init(isPresented: Bool) {
        self.isPresented = isPresented
    }
    func dismiss() {
        self.isPresented = false
    }
}

enum SelectedPanel {
    case search, layers, basemap, property
}
