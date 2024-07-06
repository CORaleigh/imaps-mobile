import SwiftUI
import ArcGIS


struct LayersView: View, Equatable {
    @StateObject var mapViewModel: MapViewModel
    @StateObject var panelVM: PanelViewModel
    @StateObject var layerVM = LayerViewModel(expanded: false)

    @State var refresh: Bool = false
    static func == (lhs: LayersView, rhs: LayersView) -> Bool {
        return true
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<mapViewModel.map.operationalLayers.count, id:\.self) { i in
                    let layer = mapViewModel.map.operationalLayers.reversed()[i]
                    SubLayerView(layer: layer, layerVM: layerVM, panelVM: panelVM)
                }
            }
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $layerVM.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by layer name")

            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing){
                    Button(action: {
                        self.panelVM.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                ToolbarTitleMenu {
                    Button {
                        expandAllLayers(mapViewModel: mapViewModel, layerVM: layerVM)
                    }
                label: {
                    HStack {
                        Image(systemName:"list.bullet.indent")
                        Text("Expand all")
                    }
                }
                    Button {
                        layerVM.objectWillChange.send()
                        layerVM.expandedLayers.removeAll()
                    }
                label: {
                    HStack {
                        Image(systemName:"list.bullet")
                        Text("Collapse all")
                    }
                    
                }
                    Button {
                        Task {
                            UserDefaults.standard.removeObject(forKey:"visibleLayers")
                            await mapViewModel.setLayerVisibility(map: mapViewModel.map)
                            self.layerVM.layersReset.toggle()
                        }
                    }
                label: {
                    HStack {
                        Image(systemName:"arrow.clockwise")
                        Text("Reset layers")
                    }
                    
                }
                }
            }
            .toolbarBackground(.visible)
            .toolbarBackground(Color("Background").opacity(0.5))
            .onAppear(){
                mapViewModel.objectWillChange.send()
            }
            .onReceive(layerVM.$searchText) { searchText in
                if searchText.count > 0 {
                    expandAllLayers(mapViewModel: mapViewModel, layerVM: layerVM)
                } else {
                    Task {
                        try await Task.sleep(nanoseconds: 250_000_000)
                        layerVM.expandedLayers.removeAll()

                    }
                    
                }
            }
            
        }
        
    }
}

struct LayersView_Previews: PreviewProvider {
    static var previews: some View {
        LayersView(mapViewModel: MapViewModel(), panelVM: PanelViewModel(isPresented: false))
    }
}

@MainActor func expandAllLayers(mapViewModel: MapViewModel, layerVM: LayerViewModel) {
    layerVM.objectWillChange.send()

    layerVM.expandedLayers = expandLayers(mapViewModel.map.operationalLayers)
}

func expandLayers(_ layers: [LayerContent]) -> [String] {
    return layers.flatMap { layerContent -> [String] in
        if let groupLayer = layerContent as? GroupLayer {
            return [groupLayer.name] + expandLayers(groupLayer.subLayerContents)
        }
        return []
    }
}
