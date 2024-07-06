import SwiftUI
import ArcGIS

struct SubLayerView: View, Equatable {
    var layer: Layer
    @ObservedObject var layerVM: LayerViewModel
    @ObservedObject var panelVM: PanelViewModel
    @State private var isExpanded = false
    
    static func == (lhs: SubLayerView, rhs: SubLayerView) -> Bool {
        return lhs.layer.id == rhs.layer.id && lhs.layer.isVisible == rhs.layer.isVisible
    }
    
    var body: some View {
        if ((layer as? GroupLayer) != nil) {
            if layerVM.searchText.count == 0 || layer.subLayerContents.filter({$0.name.lowercased().contains(layerVM.searchText.lowercased()) }).count > 0 {
                DisclosureGroup(layer.name, isExpanded: $isExpanded) {
                    ForEach(layer.subLayerContents.reversed(), id: \.self.name) { sublayer in
                        if layer is GroupLayer {
                            SubLayerView(layer: sublayer as! Layer, layerVM: layerVM, panelVM: self.panelVM)
                        } else {
                            Toggle(isOn: Binding<Bool>(
                                get: { sublayer.isVisible },
                                set: { sublayer.isVisible = $0 }
                            )) {
                                Text(sublayer.name)
                            }
                        }
                    }
                }

                .onChange(of: isExpanded) { newValue in
                    if newValue {
                        // Perform actions or display views when expanded
                        layerVM.expandedLayers.append(layer.name)
                    } else {
                        layerVM.expandedLayers = layerVM.expandedLayers.filter{$0 != layer.name}
                        
                    }
                }
                .onReceive(layerVM.$expandedLayers) { expandedLayers in
                    isExpanded = expandedLayers.contains(where: {$0 == layer.name})
                    
                }
            }

        }
        else {
            if layerVM.searchText.count == 0 || layer.name.lowercased().contains(layerVM.searchText.lowercased()) {
                NavigationLink(destination: {LayerInfoView(panelVM: self.panelVM, layer: layer)}, label: {
                    
                    Toggle(isOn: Binding<Bool>(get: {layer.isVisible}, set: {
                        var visibleLayers: Array = UserDefaults.standard.array(forKey: "visibleLayers") ?? []
                        print(layer.loadStatus)
                        layer.isVisible = $0
                        if (layer.isVisible) {
                            visibleLayers.append(layer.name)
                        } else {
                            let hasLayer = visibleLayers.contains { $0 as? String == layer.name}
                            if (hasLayer) {
                                if let i = visibleLayers.firstIndex(where: { $0 as? String == layer.name }) {
                                    visibleLayers.remove(at: i)
                                }
                            }
                        }
                        UserDefaults.standard.set(visibleLayers, forKey: "visibleLayers")
                        layerVM.objectWillChange.send() // Trigger view update

                    })) {
                        Text(layer.name)
                        
                    }
                })
                
             
            }
        }
        
    }
}

//struct SubLayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubLayerView()
//    }
//}
