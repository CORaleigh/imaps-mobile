import Foundation
import SwiftUI

class LayerViewModel: ObservableObject {
    @Published  var expanded: Bool = false
    @Published var layersReset: Bool = false
    
    init(expanded: Bool) {
        self.expanded = expanded
    }
}

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
