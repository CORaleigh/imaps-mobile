import SwiftUI
import ArcGIS


struct PropertyView: View, Equatable {
    @EnvironmentObject var mapViewModel : MapViewModel
    @EnvironmentObject var panelVM: PanelViewModel
    
    @ObservedObject var viewModel: ViewModel = ViewModel(text: "")
    
    @StateObject private var propertyVM: PropertyViewModel = PropertyViewModel(feature: nil, features: [])
    
    @State var group: SearchGroup
    @State var source: PropertySource
    
    static func == (lhs: PropertyView, rhs: PropertyView) -> Bool {
        return lhs.viewModel.text == rhs.viewModel.text
    }
    var body: some View {
        ZStack{
            Color.clear.ignoresSafeArea()
            if (self.propertyVM.features.count == 1) {
                NavigationStack {
                    
                    ScrollView {
                        PropertyInfoView(feature: FeatureViewModel(feature:self.propertyVM.feature!), fromSearch: true, fromList: false)
                            .environmentObject(mapViewModel)
                            .environmentObject(panelVM)
                        
                    }
                    
                    
                }
                
            }
            
            if (self.propertyVM.features.count > 1) {
                NavigationStack {
                    PropertyListView(features: self.propertyVM.features, fromSearch: true)
                        .environmentObject(panelVM)
                    
                }
                
            }
        }
        .onReceive(viewModel.$text) { text in
            Task {
                guard let table: ServiceFeatureTable =  mapViewModel.getCondoTable(map: mapViewModel.map) else { return }
                await queryFeatures(for: table, field: group.field, value: viewModel.text, completion: { data in
                    Task {
                        let count = data.count
                        self.propertyVM.features = []
                        self.propertyVM.objectWillChange.send()
                        if (count == 1) {
                            
                            guard let f = data.first(where: {$0.attributes["OBJECTID"] as? Int64 != nil}) else { return }
                            self.propertyVM.feature  = f
                            
                            data.forEach {
                                feature in
                                self.propertyVM.features.append(feature)
                            }
                        } else {
                            data.forEach {
                                feature in
                                self.propertyVM.features.append(feature)
                            }
                        }
                        
                        propertyVM.updateView()
                    }
                })
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


//struct PropertyView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyView(group: SearchGroup(field: "SITE_ADDRESS", alias: "Site Address", features: []), source: .search)
//
//    }
//}

