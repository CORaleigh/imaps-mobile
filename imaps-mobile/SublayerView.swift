//
//  SublayerView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS
struct SublayerView: View {
    var layer: Layer
    @EnvironmentObject var layerData: LayerData
    var body: some View {
        if ((layer as? GroupLayer) != nil) {
            DisclosureGroup(layer.name, isExpanded: $layerData.expanded) {
                ForEach(layer.subLayerContents.reversed(), id:\.self.name) {
                    sublayer in
                    if ((layer as? GroupLayer) != nil) {
                        SublayerView(layer: sublayer as! Layer)
                    } else {
                        
                        Toggle(isOn: Binding<Bool>(get: {sublayer.isVisible}, set: {sublayer.isVisible = $0;})) {
                                Text(sublayer.name)
                
                        }


                    }
                }
            }
        } else {
         
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
  

        }
    }
}

//struct SublayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SublayerView(layer: Layer())
//    }
//}
