
import SwiftUI
import ArcGIS

class MapViewModel: ObservableObject {
    @Published var viewpoint: Viewpoint? = nil
    @Published var longPressScreenPoint: CGPoint? = nil
    @Published var failedToStart = false
    @Published var locationEnabled = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
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
                try? await checkAlert()

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
            if let mapImageLayer = layer as? ArcGISMapImageLayer {
                if mapImageLayer.name == "Raleigh Stormwater" {
                    let clonedLayer = mapImageLayer.clone()
                    mapImageLayer.resetSublayers()
                    mapImageLayer.mapImageSublayers.enumerated().forEach {index, sublayer in
                        sublayer.popupsAreEnabled = clonedLayer.mapImageSublayers[index].popupsAreEnabled
                        sublayer.popupDefinition = clonedLayer.mapImageSublayers[index].popupDefinition

                    }
                }
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
            guard let geometry = property.geometry else {
                print("Error: Property geometry is nil")
                return
            }
            if let proxy = self.proxy {
                await proxy.setViewpointGeometry(geometry, padding: 100)

                DispatchQueue.main.async {
                    // Debugging statements
                    print("Graphics count before removing: \(self.graphics.graphics.count)")

                    // Remove all graphics
                    self.graphics.removeAllGraphics()

                    print("Graphics count after removing: \(self.graphics.graphics.count)")

                    // Add new graphic
                    let symbol = SimpleFillSymbol(
                        style: .noFill,
                        outline: SimpleLineSymbol(
                            style: .solid,
                            color: UIColor.red,
                            width: 2
                        )
                    )
                    let graphic = Graphic(
                        geometry: geometry,
                        attributes: property.attributes,
                        symbol: symbol
                    )
                    self.graphics.addGraphic(graphic)

                    // Debugging statements
                    print("Graphics count after adding: \(self.graphics.graphics.count)")
                }
            } else {
                print("Error: Proxy is nil")
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
    
    
    func checkAlert() async throws {
        
        guard let url = URL(string: "https://maps.raleighnc.gov/imaps-mobile/alert.json") else {
            throw NetworkError.invalidURL
        }
        URLCache.shared.removeAllCachedResponses()

        let (data, response) = try await URLSession.shared.data(from: url)
        print(data)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        guard let alertResponse = try? JSONDecoder().decode(AlertResponse.self, from: data) else {
            throw NetworkError.invalidData
        }
        DispatchQueue.main.async { [self] in
            if alertResponse.enabled == true {
                showAlert = true
                alertMessage = alertResponse.message
            }
        }
    }

    struct AlertResponse: Decodable {
        let enabled: Bool
        let message: String
        enum CodingKeys: String, CodingKey {
            case enabled
            case message
        }
    }
}
