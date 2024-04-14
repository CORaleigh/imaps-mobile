
import SwiftUI
import ArcGIS

class MapViewModel: ObservableObject {
    @Published var viewpoint: Viewpoint? = nil
    @Published var longPressScreenPoint: CGPoint? = nil
    @Published var failedToStart = false
    @Published var locationEnabled = false
    
    var map: Map
    var proxy: MapViewProxy? = nil
    var graphics: GraphicsOverlay = GraphicsOverlay(graphics: [])
    let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    var attributionBarHeight: CGFloat = 0
    
    init(map: Map) {
        self.map = map
        Task {
            try? await map.load()
            for table in self.map.tables {
                try await table.load()
            }
            await setLayerVisibility(map: map)
        }
        self.viewpoint = setViewpoint()
    }
    func getCondoTable (map: Map) -> ServiceFeatureTable? {
        let table = map.tables.first{$0.displayName.uppercased().contains("CONDO")} as? ServiceFeatureTable
        return table
    }
    func setLayerVisibility (map: Map) async -> Void {
        try? await map.load()
        let visibleLayers: Array = UserDefaults.standard.array(forKey: "visibleLayers") ?? []
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
                                        sublayer3.isVisible = visibleLayers.contains{ $0 as? String == sublayer3.name}
                                    }
                                }
                            } else if ((sublayer2.name != "Property")) {
                                sublayer2.isVisible = visibleLayers.contains{ $0 as? String == sublayer2.name}
                            }
                        }
                    } else if ((sublayer.name != "Property")) {
                        sublayer.isVisible = visibleLayers.contains{ $0 as? String == sublayer.name}
                    }
                }
            } else if ((layer.name != "Property")) {
                layer.isVisible = false;
            }
        }
    }
    func propertySelected(map: Map, property: Feature) {
        Task {
            guard let geometry = property.geometry  else { return }
            if self.proxy != nil {
                await self.proxy?.setViewpointGeometry(geometry, padding: 100)
                self.graphics.removeAllGraphics()
                
                self.graphics.addGraphic(Graphic(geometry: property.geometry, attributes: property.attributes, symbol: SimpleFillSymbol(style: SimpleFillSymbol.Style.noFill, outline: SimpleLineSymbol(style: SimpleLineSymbol.Style.solid, color: UIColor.red, width: 2))))
            }
            
        }
        
    }
    func setViewpoint () -> Viewpoint {
        var viewpoint = Viewpoint(center: Point(latitude: 35.7796, longitude: -78.6382), scale: 500_000)
        let center: String? = UserDefaults.standard.string(forKey: "center")
        let scale: Double = UserDefaults.standard.double(forKey: "scale")
        if (center != nil) {
            viewpoint = Viewpoint(center: try! Geometry.fromJSON(center!) as! Point,
                                  scale: scale)
        }
        return viewpoint
    }
    
}
