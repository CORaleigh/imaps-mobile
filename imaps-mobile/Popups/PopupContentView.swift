import SwiftUI
import ArcGIS
import ArcGISToolkit

struct PopupContentView: View {
    @ObservedObject  var popupVM: PopupViewModel
    @State var popup: Popup?
    @State var lastLayer: FeatureLayer? = nil
    @State var panelVM: PanelViewModel
    var mapViewModel: MapViewModel
    var body: some View {
        VStack {
            NavigationStack {
                GeometryReader { geo in
                    VStack (alignment: .leading) {
                        if let geoElement = popupVM.geoElement,
                           let geometry = geoElement.geometry {
                            if (geo.size.height > 30) {
                                Button(action: { zoomToPopupFeature(geometry: geometry) }) {
                                    HStack {
                                        Image(systemName: "plus.magnifyingglass")
                                        Text("Zoom To")
                                    }
                                }.padding()
                            }

                        }
                        if let popup = popupVM.popup {
                            PopupView(popup: popup, isPresented: $popupVM.isPresented)
                                .showCloseButton(false)
                                .padding()
                        }
                    }
                }
                .padding()
                    .toolbar {
                        if popupVM.popupCount > 1 {
                            ToolbarItem (placement: .topBarLeading){
                                Button(action: {
                                    if (lastLayer != nil) {
                                        lastLayer?.clearSelection()
                                    }
                                    self.popupVM.popup = nil
                                },label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Results")
                                    }
                                    
                                })
                            }
                        }
                            ToolbarItem (placement: .navigationBarTrailing){
                                Button(action: {
                                    if (lastLayer != nil) {
                                        lastLayer?.clearSelection()
                                    }
                                    self.popupVM.popup = nil
                                    self.popupVM.dismiss()
                                },label: {
                                    
                                    Image(systemName: "xmark")
                                    
                                })
                            }
                    }
                    .navigationTitle(popupVM.layerName).navigationBarTitleDisplayMode(.inline)
                Spacer()
            }
        }
        
        .onReceive(panelVM.$selectedPanel) { selectedPanel in
            lastLayer?.clearSelection()
        }
        .onReceive(popupVM.$layer.combineLatest(popupVM.$geoElement)) { layer, geoElement in

            //var featureLayer: FeatureLayer? = nil // Declare featureLayer outside guard
            if (lastLayer != nil) {
                lastLayer?.clearSelection()
            }
            if let featureLayer = layer,
               let feature = geoElement as? Feature
            {
                lastLayer = featureLayer
                featureLayer.clearSelection()
                featureLayer.selectFeature(feature)
            }


        }
        
        .onReceive(popupVM.$isPresented) { isPresented in
            if (!isPresented) {
                lastLayer?.clearSelection()
            }
        }
    }
    func zoomToPopupFeature(geometry: Geometry) {
        Task {
            await mapViewModel.proxy?.setViewpointGeometry(geometry, padding: 10.0)
        }
    }
        
}






//#Preview {
//    PopupContentView()
//}
