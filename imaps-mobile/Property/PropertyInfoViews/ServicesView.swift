import SwiftUI
import ArcGIS

struct ServicesView: View, Equatable {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var propertyInfoViewModel : PropertyInfoViewModel
    @ObservedObject var feature: FeatureViewModel
    @State  var layers: [FeatureLayer]
    @State var selectedCategory: Int = 0
    @State var layersReturned: Int = 0
    @ObservedObject var viewModel: ServicesViewModel = ServicesViewModel(services:
                                                                    [
                                                                        ServiceCategory(title: "Election", services: [
                                                                            Service(layerName: "Precincts", title: "Voting Precinct", fields: ["PRECINCT"], text: [""], expression: "{0}", capitalize: true),
                                                                            Service(layerName: "US House of Representatives Districts", title: "US House of Representatives", fields: ["DISTRICT", "NAME"], text: [""], expression: "Distict {0}\n{1}", capitalize: true),
                                                                            Service(layerName: "NC Senate Districts", title: "NC Senate", fields: ["DISTRICT", "NAME"], text: [""], expression: "Distict {0}\n{1}", capitalize: true),
                                                                            Service(layerName: "School Board Districts", title: "School Board",  fields: ["DISTRICT", "NAME"], text: [""], expression: "Distict {0}\n{1}", capitalize: true),
                                                                            Service(layerName: "Board of Commissioners Districts", title: "Board of Commissioners", fields: ["DISTRICT", "COMM_NAME"], text: [""], expression: "Distict {0}\n{1}", capitalize: true),
                                                                            Service(layerName: "District Court Judicial Districts", title: "District Court", fields: ["DISTRICT"], text: [""], expression: "District {0}", capitalize: true),
                                                                            Service(layerName: "Raleigh City Council", title: "Raleigh City Council", fields: ["COUNCIL_DIST", "COUNCIL_PERSON"], text: [""], expression: "Distict {0}\n{1}", capitalize: true),
                                                                            Service(layerName: "Cary Town Council", title: "Cary Town Council", fields: ["NAME", "REPNAME"], text: [""], expression: "District {0}\n{1}", capitalize: true),
                                                                            
                                                                        ]),
                                                                        ServiceCategory(title: "Planning", services: [
                                                                            Service(layerName: "Corporate Limits", title: "City Limit", fields: ["LONGNAME"], text: [""], expression: "{0}", capitalize: true),
                                                                            Service(layerName: "Planning Jurisdictions", title: "Planning Jurisdiction", fields: ["JURISDICTION"], text: [""], expression: "{0}", capitalize: true),
                                                                            Service(layerName: "Subdivisions", title: "Subdivision", fields: ["NAME"], text: [""], expression: "{0}", capitalize: true),
                                                                            Service(layerName: "Raleigh Zoning", title: "Zoning", fields: ["ZONING"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Future Landuse", title: "Future Land Use", fields: ["Land_Use"], text: [""], expression: "{0}", capitalize: true),
                                                                            Service(layerName: "Cary Zoning", title: "Zoning", fields: ["ZONECLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Angier Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Apex Zoning", title: "Zoning", fields: ["DISTRICT"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "County Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Fuquay-Varina Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Garner Zoning", title: "Zoning", fields: ["ZONING_NAME", "CLASS"], text: [""], expression: "{0} ({1})", capitalize: false),
                                                                            Service(layerName: "Holly Springs Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Knightdale Zoning", title: "Zoning", fields: ["ZONEDESC", "ZONECLASS"], text: [""], expression: "{0} ({1})", capitalize: false),
                                                                            Service(layerName: "Morrisville Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Rolesville Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Wake Forest Zoning", title: "Zoning", fields: ["ZoneDefine", "ZoneLabel"], text: [""], expression: "{0} ({1})", capitalize: false),
                                                                            Service(layerName: "Wendell Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false),
                                                                            Service(layerName: "Zebulon Zoning", title: "Zoning", fields: ["CLASS"], text: [""], expression: "{0}", capitalize: false)
                                                                        ]),
                                                                        ServiceCategory(title: "Solid Waste", services: [
                                                                            Service(layerName: "Raleigh Solid Waste Collection Routes", title: "Solid Waste Collection", fields: ["SERVICEDAY", "SER_WEEK"], text: [""], expression: "Service Day {0}\nService Week {1}", capitalize: true)
                                                                        ]),
                                                                        ServiceCategory(title: "Environmental", services: [
                                                                            Service(layerName: "Soils", title: "Soils", fields: ["DESCRIPTION", "MAPUNITSYMBOL"], text: [""], expression: "{0} ({1})", capitalize: false),
                                                                            Service(layerName: "Flood Hazard Areas (Floodplains)", title: "Flood Hazard Area", fields: ["ZONE_SUBTY"], text: [""], expression: "{0}", capitalize: false)
                                                                        ])
                                                                        
                                                                    ]
    )
    
    
    static func == (lhs: ServicesView, rhs: ServicesView) -> Bool {
        return true
    }
    var body: some View {
        VStack  (alignment: .leading){
            HStack (alignment: .center) {
                Text("Category").font(.subheadline)
                    .frame(maxWidth: .infinity)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(0..<viewModel.services.count, id:\.self) { i in
                        Text(viewModel.services[i].title).tag(i)
                    }
                }
                .pickerStyle(.automatic)
                .frame(maxWidth: .infinity)
                .padding(.all)
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .border(Color(UIColor.tertiarySystemBackground), width: 5)
            .cornerRadius(20)
            .padding(.all)
            
            ScrollView {
                let category = viewModel.services[selectedCategory]
                let services = category.services.filter{$0.text.first != ""}
                if services.count != 0 {
                    VStack (alignment: .leading) {
                        if layersReturned == layers.count {
                            ForEach(0..<category.services.count, id:\.self) { i in
                                if category.services[i].text != [""] {
                                    VStack (alignment: .leading){
                                        Text(category.services[i].title).font(.title2).multilineTextAlignment(.leading)
                                        ForEach(category.services[i].text, id:\.self) { text in
                                            Text(text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                    }.padding(.all)
                                    
                                }
                            }
                        }
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("No information available in this area").padding(.all)
                }
                
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color("Background"))
        
        .onChange(of: selectedCategory, perform: { index in
            let category = viewModel.services[index]
            getLayers(category: category)
            getServices(layers: self.layers, feature: propertyInfoViewModel.property!, category: category, viewModel: viewModel)
            
            
        })
        .onReceive(propertyInfoViewModel.$property) { feature in
            
            if feature != nil {
                let category = viewModel.services[selectedCategory]
                
                getLayers(category: category)
                getServices(layers: self.layers, feature: feature!, category: category, viewModel: viewModel)
            }
            
            
            
        }.frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    func getLayers(category: ServiceCategory) {
        let layerNames = category.services.map { $0.layerName }
        self.layers = []
        mapViewModel.map.operationalLayers.forEach { layer in
            if layerNames.contains(layer.name) && (layer as? FeatureLayer) != nil {
                self.layers.append(layer as! FeatureLayer)
            }
            if (layer as? GroupLayer) != nil {
                layer.subLayerContents.forEach { sublayer in
                    if layerNames.contains(sublayer.name) && (sublayer as? FeatureLayer) != nil {
                        self.layers.append(sublayer as! FeatureLayer)
                    }
                    if (sublayer as? GroupLayer) != nil {
                        sublayer.subLayerContents.forEach { sublayer2 in
                            if layerNames.contains(sublayer2.name) && (sublayer2 as? FeatureLayer) != nil {
                                self.layers.append(sublayer2 as! FeatureLayer)
                            }
                            if (sublayer2 as? GroupLayer) != nil {
                                sublayer2.subLayerContents.forEach { sublayer3 in
                                    if layerNames.contains(sublayer3.name) && (sublayer3 as? FeatureLayer) != nil {
                                        self.layers.append(sublayer3 as! FeatureLayer)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func getPollPlaceLayer() -> FeatureLayer? {
        var pollLayer: FeatureLayer?
        mapViewModel.map.operationalLayers.forEach { layer in
            if layer.name == "Polling Places" && (layer as? FeatureLayer) != nil {
                pollLayer = layer as? FeatureLayer
            }
            if (layer as? GroupLayer) != nil {
                layer.subLayerContents.forEach { sublayer in
                    if sublayer.name == "Polling Places" && (sublayer as? FeatureLayer) != nil {
                        pollLayer = sublayer as? FeatureLayer
                    }
                    if (sublayer as? GroupLayer) != nil {
                        sublayer.subLayerContents.forEach { sublayer2 in
                            if sublayer2.name == "Polling Places" && (sublayer2 as? FeatureLayer) != nil {
                                pollLayer = sublayer2 as? FeatureLayer
                            }
                            if (sublayer2 as? GroupLayer) != nil {
                                sublayer2.subLayerContents.forEach { sublayer3 in
                                    if sublayer3.name == "Polling Places" && (sublayer3 as? FeatureLayer) != nil {
                                        pollLayer = sublayer3 as? FeatureLayer
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return pollLayer!
    }
    func getPollingPlace(pollPlaces: [Feature], category: ServiceCategory) throws {
        guard let pollPlace: Feature = pollPlaces.first  else { return }
        guard var cat = viewModel.services.filter({$0.title == category.title}).first  else { return }
        
        let place = pollPlace.attributes["POLL_PL"] ?? "",
            stNumber = pollPlace.attributes["ST_NUMBER"] ?? "",
            stName = pollPlace.attributes["ST_NAME"] ?? "",
            city = pollPlace.attributes["CITY"] ?? "",
            text = "\(place)\n\(stNumber) \(stName)\n\(city)".capitalized.replacingOccurrences(of: ", Nc", with: ", NC"),
            p = cat.services.first{$0.layerName == "Polling Places"}
        if p != nil {
            cat.services.remove(at: 1)
        }
        cat.services.insert(Service(layerName: "Polling Places", title: "Polling Place", fields: ["POLL_PL"], text: [text], expression: "", capitalize: true), at: 1)
        viewModel.services[0] = cat
    }
    func getServices(layers: [FeatureLayer], feature:Feature, category: ServiceCategory, viewModel: ServicesViewModel) {
        self.layersReturned = 0
        layers.forEach { layer in
            Task {
                let features: [Feature] = try await queryServices(for: layer, propertyFeature: feature)
                self.layersReturned += 1
                
                if layer.name == "Precincts" {
                    
                    let pollLayer = getPollPlaceLayer()
                    if pollLayer != nil {
                        let pollPlaces: [Feature] = try await queryPollingPlaces(for: pollLayer!, whereClause: "PRECINCT = '\(features.first!.attributes["PRECINCT"] as! String)'")
                        do {
                            try getPollingPlace(pollPlaces: pollPlaces, category: category)
                            
                        } catch {
                            
                        }
                        viewModel.objectWillChange.send()
                    }
                    
                }
                
                DispatchQueue.main.async {
                    let category = viewModel.services.filter{$0.title == category.title}.first
                    let service = category!.services.filter{$0.layerName == layer.name}.first
                    if !features.isEmpty {
                        service!.text.removeAll()
                        features.forEach { feature in
                            var text = service?.expression
                            service!.fields.enumerated().forEach { i, field in
                                let value = feature.attributes[field] ?? ""
                                
                                text = (text!.replacingOccurrences(of: "{\(i)}", with: value as! String))
                                if service?.capitalize == true {
                                    text = text?.capitalized
                                }
                            }
                            if service!.text.first(where: {$0 == text}) == nil {
                                service!.text.append(text!)
                            }
                        }
                        viewModel.objectWillChange.send()
                    }
                    
                }
            }
            
        }
    }
}

//#Preview {
//    ServicesView()
//}
