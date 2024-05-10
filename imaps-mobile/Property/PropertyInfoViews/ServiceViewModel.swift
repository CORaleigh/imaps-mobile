import SwiftUI
import ArcGIS
@MainActor
class ServiceViewModel: ObservableObject {
    @Published var categories: [Category]
    @Published var popupGroups: [PopupGroup]
    @Published var popups: [Popup]

    var mapViewModel: MapViewModel
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
        self.popupGroups = []
        self.popups = []
        self.categories = [
            Category(title: "Election", layers: [
                getLayer(name: "Precincts", mapViewModel: mapViewModel),
                getLayer(name: "US House of Representatives Districts", mapViewModel: mapViewModel),
                getLayer(name: "NC Senate Districts", mapViewModel: mapViewModel),
                getLayer(name: "School Board Districts", mapViewModel: mapViewModel),
                getLayer(name: "Board of Commissioners Districts", mapViewModel: mapViewModel),
                getLayer(name: "District Court Judicial Districts", mapViewModel: mapViewModel),
                getLayer(name: "Raleigh City Council", mapViewModel: mapViewModel),
                getLayer(name: "Cary Town Council", mapViewModel: mapViewModel),
                
            ]),
            Category(title: "Planning", layers: [
                getLayer(name: "Corporate Limits", mapViewModel: mapViewModel),
                getLayer(name: "Planning Jurisdictions", mapViewModel: mapViewModel),
                getLayer(name: "Subdivisions", mapViewModel: mapViewModel),
                getLayer(name: "Raleigh Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Future Landuse", mapViewModel: mapViewModel),
                getLayer(name: "Cary Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Angier Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Apex Zoning", mapViewModel: mapViewModel),
                getLayer(name: "County Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Fuquay-Varina Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Garner Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Holly Springs Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Knightdale Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Morrisville Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Rolesville Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Wake Forest Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Wendell Zoning", mapViewModel: mapViewModel),
                getLayer(name: "Zebulon Zoning", mapViewModel: mapViewModel),
            ]),
            Category(title: "Solid Waste", layers: [
                getLayer(name: "Raleigh Solid Waste Collection Routes", mapViewModel: mapViewModel),
            ]),
            Category(title: "Environmental", layers: [
                getLayer(name: "Soils", mapViewModel: mapViewModel),
                getLayer(name: "Flood Hazard Areas (Floodplains)", mapViewModel: mapViewModel),
            ])
            
        ]
    }
    func getPopupsForLayer(layer: Layer, selectedGeometry: Geometry) async throws -> PopupGroup?{
        var popupGroup: PopupGroup? = nil

        if let featureLayer = layer as? FeatureLayer,
           let featureTable = featureLayer.featureTable as? ServiceFeatureTable {
            let params = QueryParameters()
            params.returnsGeometry = true
            params.geometry = selectedGeometry
            params.whereClause = "1=1"
            do {
                let results = try await featureTable.queryFeatures(using: params, queryFeatureFields: .loadAll)
                for result in results.features() {
       
                        let popup = Popup(geoElement: result, definition: featureLayer.popupDefinition)

                        do {

                            _ = try await popup.evaluateExpressions()
                            popupGroup = PopupGroup(title: popup.title, popupElements: popup.evaluatedElements, layer: featureLayer)
                        } catch {
                            // Handle error evaluating expressions
                            print("Error evaluating expressions: \(error)")
                        }
                    
                }
            } catch {
                // Handle query features error
                print("Query features error: \(error)")
            }
            

        }
        return popupGroup

    }
    
    func getPopupsForLayers(layers: [Layer?], geometry: Geometry) async throws -> [PopupGroup] {
        var groups: [PopupGroup] = []
        var tasks: [Task<[PopupGroup], Error>] = []

        for layer in layers {
            if let layer = layer {
                let task = Task<[PopupGroup], Error> {
                    do {
                        let popupGroup = try await self.getPopupsForLayer(layer: layer, selectedGeometry: geometry)
                        return [popupGroup].compactMap { $0 }
                    } catch {
                        // Handle errors from asynchronous function
                        print("Error: \(error)")
                        return []
                    }
                }
                tasks.append(task)
            }
        }

        for task in tasks {
            do {
                let result = try await task.value
                groups.append(contentsOf: result)
            } catch {
                // Handle error if any task fails
                print("Error: \(error)")
            }
        }

        return groups
    }

    
//    func getPopupsForLayers(layers: [Layer?], geometry: Geometry) async throws -> [PopupGroup] {
//        var groups: [PopupGroup] = []
//        for layer in layers {
//            // Safely unwrap optionals
//                Task {
//                    do {
//                        // Await the asynchronous function
//                        if layer != nil {
//                            let popupGroup = try await self.getPopupsForLayer(layer: layer!, selectedGeometry: geometry)
//                            if ((popupGroup) != nil) {
//                                groups.append(popupGroup!)
//                            }
//                            
//                        }
//                        
//                    } catch {
//                        // Handle errors from asynchronous function
//                        print("Error: \(error)")
//                    }
//                }
//        }
//        return groups
//    }
    
    func getPopups(selectedCategory: Category, property: Feature?) async throws {
        self.popupGroups.removeAll()
        
        guard let propertyGeometry = property?.geometry else {
            // Handle the case where property is nil or its geometry is nil
            return
        }
        
        do {
            let groups = try await getPopupsForLayers(layers: selectedCategory.layers, geometry: propertyGeometry)
            self.popupGroups = groups
        } catch {
            // Handle the error thrown by getPopupsForLayers
            print("Error getting popups:", error)
            throw error // Re-throw the error if needed
        }
    }

}

struct Category: Hashable, Identifiable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return true
    }
    var id: UUID { UUID() }
    
    let title: String
    var layers: [Layer?]
    init(title: String, layers: [Layer?]) {
        self.title = title
        self.layers = layers
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

func getLayer(name: String, mapViewModel: MapViewModel) -> Layer? {
    func findLayer(layer: Layer) -> Layer? {
        if layer.name == name {
            return layer
        } else if let groupLayer = layer as? GroupLayer {
            for subLayer in groupLayer.layers {
                if let foundLayer = findLayer(layer: subLayer) {
                    return foundLayer
                }
            }
        }
        return nil
    }

    for layer in mapViewModel.map.operationalLayers {
        if let foundLayer = findLayer(layer: layer) {
            return foundLayer
        }
    }
    return nil
}





struct PopupGroup: Identifiable {
    var id: UUID { UUID() }

    var title: String
    var popupElements: [PopupElement]
    var layer: Layer
}
