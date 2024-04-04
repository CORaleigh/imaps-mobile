import SwiftUI
import ArcGIS

struct SubLayerView: View {
    var layer: Layer
    @StateObject var layerVM: LayerViewModel
    
    var body: some View {
        if ((layer as? GroupLayer) != nil) {
            DisclosureGroup(layer.name, isExpanded: $layerVM.expanded) {
                ForEach(layer.subLayerContents.reversed(), id:\.self.name) {
                    sublayer in
                    if ((layer as? GroupLayer) != nil) {
                        SubLayerView(layer: sublayer as! Layer, layerVM: layerVM)
                    } else {
                        
                        Toggle(isOn: Binding<Bool>(get: {sublayer.isVisible}, set: {sublayer.isVisible = $0;})) {
                            Text(sublayer.name)
                        }
                    }
                }
            }
        }
        else {
            NavigationLink(destination: {LayerInfoView(layer: layer)}, label: {
                
                Toggle(isOn: Binding<Bool>(get: {layer.isVisible}, set: {
                    var visibleLayers: Array? = UserDefaults.standard.array(forKey: "visibleLayers") ?? []
                    layer.isVisible = $0
                    if (layer.isVisible) {
                        visibleLayers?.append(layer.name)
                    } else {
                        let hasLayer = visibleLayers?.contains { $0 as? String == layer.name}
                        if (hasLayer!) {
                            if let i = visibleLayers!.firstIndex(where: { $0 as? String == layer.name }) {
                                visibleLayers?.remove(at: i)
                            }
                        }
                    }
                    UserDefaults.standard.set(visibleLayers, forKey: "visibleLayers")
                })) {
                    Text(layer.name)
                    
                }
            })
            .onAppear() {
                layerVM.objectWillChange.send()
            }
            
        }
        
    }
}

//struct SubLayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubLayerView()
//    }
//}
