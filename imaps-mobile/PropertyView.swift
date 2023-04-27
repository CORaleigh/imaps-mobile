//
//  PropertyView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/25/23.
//

import SwiftUI
import ArcGIS


class ViewModel: ObservableObject {
    @Published var text: String
    init(text: String) {
        self.text = text
    }
}
class PropertyViewModel: ObservableObject {
    @Published var feature: Feature?
    @Published var features: [Feature]
    @Published var text: String = ""
    init(feature: Feature?, features: [Feature]) {
        self.feature = feature
        self.features = features
    }
    func updateView(){
        self.objectWillChange.send()
    }

}

enum PropertySource {
    case search, map, history
}

struct PropertyView: View {
    @EnvironmentObject var dataModel : MapDataModel
    @EnvironmentObject var panelVM: PanelViewModel

    @ObservedObject var viewModel: ViewModel = ViewModel(text: "")

    @ObservedObject private var propertyVM: PropertyViewModel = PropertyViewModel(feature: nil, features: [])

    @State var group: SearchGroup
    @State var source: PropertySource
    
    var body: some View {
        NavigationView {
            VStack {
                if (self.propertyVM.features.count == 1) {
                    PropertyInfoView(feature: self.propertyVM.feature!, fromSearch: true)
                            .environmentObject(dataModel)
                            .environmentObject(panelVM)


                    
       


                } else if (self.propertyVM.features.count > 1) {
                    PropertyListView(features: self.propertyVM.features, fromSearch: true)
                        .environmentObject(panelVM)


                        
                    
                }
            }
            .onReceive(viewModel.$text) { text in
                    Task {
                        let table: ServiceFeatureTable = await dataModel.getCondoTable(map: dataModel.map)!
                        await queryFeatures(for: table, field: group.field, value: viewModel.text, completion: { data in
                            Task {
                                let count = Array(data).count
                                self.propertyVM.features = []

                                if (count == 1) {
                                    let f = data.first(where: {$0.attributes["OBJECTID"] as? Int64 != nil})
                                    self.propertyVM.feature  = f!
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
                    
                }        .navigationBarHidden(true)

        }

        .navigationViewStyle(StackNavigationViewStyle())

    }
}

func queryFeatures(for table: ServiceFeatureTable, field: String, value: String, completion: @escaping (AnySequence<Feature>) -> Void) async {
    let params = QueryParameters()
    params.whereClause = "\(field) = '\(value)'"
    params.addOrderByField(OrderBy(fieldName: "SITE_ADDRESS", sortOrder: .ascending))
    let result = try? await table.queryFeatures(using: params, queryFeatureFields: .loadAll)
    completion((result?.features())!)
}

//struct PropertyView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyView(group: SearchGroup(field: "SITE_ADDRESS", alias: "Site Address", features: []), source: .search)
//
//    }
//}
