import SwiftUI
import ArcGISToolkit

@MainActor
class PanelViewModel: ObservableObject {
    @Published var isPresented: Bool
    @Published var selectedDetent: FloatingPanelDetent = .full
    @Published var size: CGSize = CGSize(width: 0, height: 0)
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
