//
//  LayersView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/25/23.
//

import SwiftUI
import ArcGIS

class LayerViewModel: ObservableObject {
    @Published  var expanded: Bool = false
    @Published var layersReset: Bool = false
    init(expanded: Bool) {
        self.expanded = expanded
    }
}

struct LayersView: View {
    @EnvironmentObject var dataModel: MapDataModel
    @EnvironmentObject var panelVM: PanelViewModel

    var layerVM = LayerViewModel(expanded: false)

    var body: some View {
        NavigationView {
            NavigationStack {
                VStack {
                    List {
                        ForEach(0..<dataModel.map.operationalLayers.count, id:\.self) { i in
                            let layer = dataModel.map.operationalLayers[i]
                            SubLayerView(layer: layer)
                                .environmentObject(self.layerVM)
                        }
                    }
                    .toolbar {
                        ToolbarTitleMenu {
//                            Button("Expand All") {
//                                self.layerVM.expanded = true
//                            }
//                            Button("Collapse All") {
//                                self.layerVM.expanded = false
//                            }
                            Button("Reset Layers") {
                                Task {
                                    UserDefaults.standard.removeObject(forKey:"visibleLayers")
                                    await dataModel.setLayerVisibility(map: dataModel.map)
                                    self.layerVM.layersReset.toggle()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Layers")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem (placement: .navigationBarTrailing){
                        Button(action: {
                            self.panelVM.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }
                }

            }
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct LayersView_Previews: PreviewProvider {
    static var previews: some View {
        LayersView()
    }
}
