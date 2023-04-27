//
//  LayerInfoView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/26/23.
//

import SwiftUI
import ArcGIS
class LegendSwatch: ObservableObject, Identifiable , Hashable {
    static func == (lhs: LegendSwatch, rhs: LegendSwatch) -> Bool {
        return lhs.label == rhs.label && lhs.swatch == rhs.swatch
    }
    @Published var label: String
    @Published var swatch: UIImage

    init(label: String, swatch: UIImage) {
        self.label = label
        self.swatch = swatch
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
        hasher.combine(swatch)
    }
}

struct LayerInfoView: View {
    @EnvironmentObject var panelVM: PanelViewModel

    @State var layer: Layer
    @State private var swatches: [LegendSwatch] = []

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
                ForEach(swatches, id: \.self) { swatch in
                    HStack {
                        Image(uiImage: swatch.swatch)
                        Text(swatch.label)
                    }
                }
            }
        }
        .task {
            let infos: [LegendInfo] = try! await layer.legendInfos
            infos.forEach { info in
                Task {
                    let swatch = try? await info.symbol?.makeSwatch(scale: 1.0)
                    self.swatches.append(LegendSwatch(label: info.name, swatch: swatch!))
                }
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
