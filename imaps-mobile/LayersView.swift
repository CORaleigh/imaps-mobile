//
//  LayersView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS
class LayerData: ObservableObject {
    @Published  var expanded: Bool = false
    @Published var layersReset: Bool = false
    init(expanded: Bool) {
        self.expanded = expanded
    }
}
struct LayersView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var shared: SharedData
    @ObservedObject private var layerData: LayerData = LayerData(expanded: false)
    var body: some View {
       // NavigationView {
            VStack {
                List {
                    ForEach(0..<shared.map.operationalLayers.count, id:\.self) { i in
                        let layer = shared.map.operationalLayers[i]
                        SublayerView(layer: layer)
                            .environmentObject(self.layerData)
                    }
                }
            }
      //  }
        .toolbar {
//            Button("Close") {
//                self.presentationMode.wrappedValue.dismiss()
//            }
            ToolbarItem(placement: .primaryAction) {
              Button("Close") {
                  self.presentationMode.wrappedValue.dismiss()
              }
            }
            ToolbarTitleMenu {
                Button("Expand All") {
                    self.layerData.expanded = true
                }
                Button("Collapse All") {
                    self.layerData.expanded = false
                }
                Button("Reset Layers") {
                    Task {
                        UserDefaults.standard.removeObject(forKey:"visibleLayers")
                        await setLayerVisibility(map: shared.map, layersLoaded: false)
                        layerData.layersReset.toggle()
                    }
                }
            }
        }
        .navigationTitle("Layers")
        .navigationBarTitleDisplayMode(.inline)
       // .navigationViewStyle(.stack)
    }
}

//struct LayersView_Previews: PreviewProvider {
//    static var previews: some View {
//        LayersView()
//    }
//}
