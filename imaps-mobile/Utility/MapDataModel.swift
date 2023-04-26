// Copyright 2022 Esri.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import SwiftUI
import ArcGIS

/// A very basic data model class containing a Map. Since a `Map` is not an observable object,
/// clients can use `MapDataModel` as an example of how you would store a map in a data model
/// class. The class inherits from `ObservableObject` and the `Map` is defined as a @Published
/// property. This allows SwiftUI views to be updated automatically when a new map is set on the model.
/// Being stored in the model also prevents the map from continually being created during redraws.
/// The data model class would be expanded upon in client code to contain other properties required
/// for the model.
class MapDataModel: ObservableObject {
    /// The `Map` used for display in a `MapView`.
    @Published var map: Map
    @Published var table: ServiceFeatureTable? = nil
    @Published var proxy: MapViewProxy? = nil
    @Published var graphics: GraphicsOverlay
    @Published var viewpoint: Viewpoint? = nil

    /// Creates a `MapDataModel`.
    /// - Parameter map: The `Map` used for display.
    init(map: Map, graphics: GraphicsOverlay, viewpoint: Viewpoint) {
        self.map = map
        self.graphics = graphics
        Task {
            try? await map.load()
            for table in self.map.tables {
                try await table.load()
            }
            await setLayerVisibility(map: map)
        }
    }
    func getCondoTable (map: Map) async -> ServiceFeatureTable? {
        let table = map.tables.first{$0.displayName.uppercased().contains("CONDO")} as? ServiceFeatureTable
        return table
    }
    func setLayerVisibility (map: Map) async -> Void {
            try? await map.load()
           // if (!layersLoaded) {
                //make all group layers visible by default
                let visibleLayers: Array? = UserDefaults.standard.array(forKey: "visibleLayers") ?? []
                map.operationalLayers.forEach { layer in
                    if ((layer as? GroupLayer) != nil) {
                        layer.isVisible = true
                        layer.subLayerContents.forEach { sublayer in
                            if ((sublayer as? GroupLayer) != nil) {
                                sublayer.isVisible = true
                                sublayer.subLayerContents.forEach { sublayer2 in
                                    if ((sublayer2 as? GroupLayer) != nil) {
                                        sublayer2.isVisible = true
                                        sublayer2.subLayerContents.forEach { sublayer3 in
                                            if ((sublayer3 as? GroupLayer) != nil) {
                                                sublayer3.isVisible = true
                                            } else if ((sublayer3.name != "Property")) {
                                                sublayer3.isVisible = visibleLayers!.contains{ $0 as? String == sublayer3.name}
                                            }
                                        }
                                    } else if ((sublayer2.name != "Property")) {
                                        sublayer2.isVisible = visibleLayers!.contains{ $0 as? String == sublayer2.name}
                                    }
                                }
                            } else if ((sublayer.name != "Property")) {
                                sublayer.isVisible = visibleLayers!.contains{ $0 as? String == sublayer.name}
                            }
                        }
                    } else if ((layer.name != "Property")) {
                        layer.isVisible = false;
                    }
                }
            }
    func propertySelected(map: Map, property: Feature) {
        Task {
            await self.proxy!.setViewpointGeometry((property.geometry)!, padding: 100)
            self.graphics.removeAllGraphics()
        
            self.graphics.addGraphic(Graphic(geometry: property.geometry, attributes: property.attributes, symbol: SimpleFillSymbol(style: SimpleFillSymbol.Style.noFill, outline: SimpleLineSymbol(style: SimpleLineSymbol.Style.solid, color: UIColor.red, width: 2))))
        }

    }
}



