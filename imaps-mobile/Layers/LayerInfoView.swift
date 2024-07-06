import SwiftUI
import ArcGIS


struct LayerInfoView: View {
    @ObservedObject var panelVM: PanelViewModel
    
    @State var layer: Layer
    @State private var legendItems: [LegendItem] = []
    @State private var loaded: Bool =  false
    @State private var counter = 0
    
    var body: some View {
        ScrollView {
            
            VStack {
                Text("Opacity")
                Slider(value: $layer.opacity, in: 0...1, step: 0.1) {
                    
                }
            minimumValueLabel: {
                Text("0%")
            } maximumValueLabel: {
                Text("100%")
            }
                ForEach(legendItems, id: \.self) { legendItem in
                    VStack {
                        Text(legendItem.label)
                            .font(.title2)
                        ForEach(legendItem.swatches, id: \.self) { swatch in
                            HStack {
                                Image(uiImage: swatch.swatch)
                                Text(swatch.label)
                            }
                        }
    
                    }
                    Spacer().padding()
                }
            }
        }
        .background(Color("Background"))
        .task {
            do {
                if let mapImageLayer = layer as? ArcGISMapImageLayer {
                    let sublayers = mapImageLayer.mapImageSublayers
                    for sublayer in sublayers {
                        let legendItem = LegendItem(label: sublayer.name, swatches: [])

                        let infos: [LegendInfo] = try await sublayer.legendInfos
                        for info in infos {
                            do {
                                if let symbol = try await info.symbol?.makeSwatch(scale: 1.0) {
                                    legendItem.swatches.append(LegendSwatch(label: info.name, swatch: symbol))
                                } else {
                                    // Handle the case where symbol is nil
                                }
                            } catch {
                                // Handle error occurred during symbol swatch creation
                                print("Error creating symbol swatch: \(error)")
                            }
                        }
                        self.legendItems.append(legendItem)
                    }
                } else {
                    let infos: [LegendInfo] = try await layer.legendInfos
                    let legendItem = LegendItem(label: layer.name, swatches: [])

                    for info in infos {
                        do {
                            if let symbol = try await info.symbol?.makeSwatch(scale: 1.0) {
                                legendItem.swatches.append(LegendSwatch(label: info.name, swatch: symbol))
                            } else {
                                // Handle the case where symbol is nil
                            }
                        } catch {
                            // Handle error occurred during symbol swatch creation
                            print("Error creating symbol swatch: \(error)")
                        }
                    }
                    self.legendItems.append(legendItem)
                }
            } catch {
                // Handle error occurred during fetching legendInfos
                print("Error fetching legend infos: \(error)")
            }
        }

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

//struct LayerInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        LayerInfoView()
//    }
//}
