import SwiftUI
import ArcGIS


struct PropertyView: View, Equatable {
    @ObservedObject var viewModel: ViewModel = ViewModel(text: "")
    @State var group: SearchGroup
    @State var source: PropertySource
    @ObservedObject var mapViewModel : MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    @StateObject private var propertyVM: PropertyViewModel = PropertyViewModel(feature: nil, features: [])
    
    static func == (lhs: PropertyView, rhs: PropertyView) -> Bool {
        return lhs.viewModel.text == rhs.viewModel.text
    }
    var body: some View {
        ZStack{
            if (self.propertyVM.features.count == 1) {
                ScrollView {
                    if self.propertyVM.feature != nil {
                        PropertyInfoView(mapViewModel: mapViewModel, panelVM: panelVM, feature:FeatureViewModel(feature:self.propertyVM.feature!))
                    }
                }
            }
            
            if (self.propertyVM.features.count > 1) {
                PropertyListView(mapViewModel: mapViewModel, panelVM: self.panelVM, propertyVM: self.propertyVM, fromSearch: true)
                
            }
        }

        .onReceive(viewModel.$text) { text in
            Task {
                var data: [Feature] = []
                guard let condoTable: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
                if group.field == "ADDRESS" {
                    guard let addressTable: ServiceFeatureTable =  mapViewModel.getAddressTable(map: mapViewModel.map) else { return }
                    guard let info = addressTable.layerInfo?.relationshipInfos.first else { return }

                    await queryRelatedCondos(for: addressTable, relationshipInfo: info, address: viewModel.text) { result in
                        data = result
                    }
                    
                } else {
                    
                    await queryFeatures(for: condoTable, field: group.field, value: viewModel.text, completion: { result in
                        data = result
                        })
                    }
                
                Task {
                    let count = data.count
                    self.propertyVM.features = []
                    self.propertyVM.objectWillChange.send()
                    if (count == 1) {
                        
                        guard let f = data.first(where: {$0.attributes["OBJECTID"] as? Int64 != nil}) else { return }
                        self.propertyVM.feature  = f
                        self.panelVM.selectedPinNum = f.attributes["PIN_NUM"] as? String ?? ""
                        data.forEach {
                            feature in
                            self.propertyVM.features.append(PropertyFeature(feature: feature))
                        }
                    } else {
                        data.forEach {
                            feature in
                            self.propertyVM.features.append(PropertyFeature(feature: feature))
                        }
                    }
                    
                    propertyVM.updateView()
                }
                if self.source == .search {
                    let encoder = JSONEncoder()
                    if (self.source == .search) {
                        let history = updateStorageHistory(field: group.field, value: viewModel.text)
                        if let encoded = try? encoder.encode(history) {
                            UserDefaults.standard.set(encoded, forKey: "searchHistory")
                        }
                        
                    }
                    
                }
            }
            
        }
    }
}


struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView(viewModel: ViewModel(text: ""),  group: SearchGroup(field: "SITE_ADDRESS", alias: "Site Address", features: []), source: .search,mapViewModel: MapViewModel(
            map: Map (
                item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
            )
        ), panelVM: PanelViewModel(isPresented: false))
        
    }
}


