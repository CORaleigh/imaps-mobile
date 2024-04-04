import SwiftUI
import ArcGIS


struct LayersView: View, Equatable {
    @StateObject var mapViewModel: MapViewModel
    @EnvironmentObject var panelVM: PanelViewModel
    @State var refresh: Bool = false
    static func == (lhs: LayersView, rhs: LayersView) -> Bool {
        return true
    }
    var layerVM = LayerViewModel(expanded: false)
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<mapViewModel.map.operationalLayers.count, id:\.self) { i in
                    let layer = mapViewModel.map.operationalLayers[i]
                    SubLayerView(layer: layer, layerVM: layerVM)
                        .environmentObject(self.layerVM)
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
                ToolbarTitleMenu {
                    Button {
                        self.layerVM.expanded = true
                    }
                label: {
                    HStack {
                        Image(systemName:"list.bullet.indent")
                        Text("Expand all")
                    }
                }
                    Button {
                        self.layerVM.expanded = false
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
            .onAppear(){
                mapViewModel.objectWillChange.send()
            }
            
        }
        
    }
}

//struct LayersView_Previews: PreviewProvider {
//    static var previews: some View {
//        LayersView()
//    }
//}
