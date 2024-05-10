
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
    
    
    init() {
        guard let portalItemID = PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4") else {
            // Handle the case when the portal item ID is nil
            print("Invalid portal item ID")
            map = Map()
            return
        }
        
        let portalItem = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: portalItemID)
        map = Map(item: portalItem)
        
        Task {
            do {
 
                    try await map.load()
                    for table in map.tables {
                        try await table.load()
                    }
                    await setLayerVisibility(map: map)
               
            } catch {
                // Handle the error
                print("Error loading map:", error)
            }
        }
        self.viewpoint = setViewpoint()

    }

    
//    init(map: Map) {
//        self.map = map
//        Task {
//            try? await map.load()
//            for table in self.map.tables {
//                try await table.load()
//            }
//            await setLayerVisibility(map: map)
//        }
//        self.viewpoint = setViewpoint()
//    }
    func getCondoTable (map: Map) -> ServiceFeatureTable? {
        let table = map.tables.first{$0.displayName.uppercased().contains("CONDO")} as? ServiceFeatureTable
        return table
    }
    func getAddressTable (map: Map) -> ServiceFeatureTable? {
        let table = map.tables.first{$0.displayName.uppercased().contains("ADDRESS")} as? ServiceFeatureTable
        return table
    }

    func setLayerVisibility (map: Map) async -> Void {
        try? await map.load()
        let visibleLayers = UserDefaults.standard.array(forKey: "visibleLayers") as? [String] ?? []
        
        func setVisibility(_ layer: Layer) {
            layer.isVisible = true
            
            if let groupLayer = layer as? GroupLayer {
                for sublayer in groupLayer.layers {
                    setVisibility(sublayer)
                }
            } else if layer.name != "Property" {
                layer.isVisible = visibleLayers.contains(layer.name)
            }
        }

        for layer in map.operationalLayers {
            if layer.name == "Property" {
                layer.isVisible = true
            } else {
                setVisibility(layer)
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
    func setViewpoint() -> Viewpoint {
        var viewpoint = Viewpoint(center: Point(latitude: 35.7796, longitude: -78.6382), scale: 500_000)
        
        if let centerJSON = UserDefaults.standard.string(forKey: "center"),
           let centerGeometry = try? Geometry.fromJSON(centerJSON) as? Point,
           let scale = UserDefaults.standard.value(forKey: "scale") as? Double {
            viewpoint = Viewpoint(center: centerGeometry, scale: scale)
        }
        
        return viewpoint
    }
    
}
