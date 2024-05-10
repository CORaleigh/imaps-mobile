import SwiftUI
import ArcGIS
struct SearchItemView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    
    @State var text: String
    @State var group: SearchGroup
    var body: some View {
        NavigationLink(text) {
            PropertyView(viewModel: ViewModel(text: text), group: group, source: .search,
                         mapViewModel: self.mapViewModel, panelVM: self.panelVM
            )
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    static var previews: some View {
        SearchItemView(mapViewModel: MapViewModel(), panelVM: PanelViewModel(isPresented: false), text: "222 W HARGETT ST", group: SearchGroup(field: "SITE_ADDRESS", alias: "ADDRESS", features: [SearchItem(feature: SearchFeature(attributes: Attributes(siteAddress: "SITE_ADDRESS", fullStreetName: "FULL_STREET_NAME", owner: "OWNER", reid: "REID", pin: "PIN")))]))
    }
}


