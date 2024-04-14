import SwiftUI

struct PanelContentView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    @ObservedObject  var basemapVM: BasemapViewModel
    var body: some View {
        ZStack {
            switch self.panelVM.selectedPanel {
            case .search:
                SearchView(mapViewModel: self.mapViewModel, panelVM: self.panelVM)
            case .layers:
                LayersView(mapViewModel: self.mapViewModel, panelVM: self.panelVM)
            case .basemap:
                BasemapView(mapViewModel: self.mapViewModel, panelVM: self.panelVM, basemapVM: self.basemapVM)
            case .property:
                PropertyView(viewModel: ViewModel(text: self.panelVM.selectedPinNum), group: SearchGroup(field: "PIN_NUM", alias: "PIN", features: []), source: .map, mapViewModel: self.mapViewModel, panelVM: self.panelVM)
            }
            
        }
        .background(Color("Background"))
    }
}

//#Preview {
//    PanelContentView()
//}
