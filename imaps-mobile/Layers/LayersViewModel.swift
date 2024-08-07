import Foundation
import SwiftUI
import ArcGIS

class LayerViewModel: ObservableObject, Equatable {
    static func == (lhs: LayerViewModel, rhs: LayerViewModel) -> Bool {
        return true
    }
    @Published var expanded: Bool = false
    @Published var layersReset: Bool = false
    @Published var expandedLayers: [String] = []
    @Published var searchText: String = ""

    init(expanded: Bool) {
        self.expanded = expanded
    }
}

class LegendItem: ObservableObject, Identifiable , Hashable {
    static func == (lhs: LegendItem, rhs: LegendItem) -> Bool {
        return lhs.label == rhs.label && lhs.swatches == rhs.swatches
    }
    @Published var label: String
    @Published var swatches: [LegendSwatch]
    init(label: String, swatches: [LegendSwatch]) {
        self.label = label
        self.swatches = swatches
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
        hasher.combine(swatches)
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



