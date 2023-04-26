//
//  BasemapView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS

class BasemapModel: ObservableObject {
    @Published var selected = "Maps"
    init(selected: String = "Maps") {
        self.selected = selected
    }
}

struct BasemapView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var shared: SharedData
    @State var basemaps: [PortalItem] = [];
    var selections = ["Maps", "Images", "Esri"]
    @ObservedObject private var model: BasemapModel = BasemapModel(selected: "Maps")
    
    var body: some View {
       // NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(basemaps, id:\.self.title) { basemap in
                            ZStack {
                                if (basemap.title == shared.map.basemap?.item?.title || basemap.title == shared.map.basemap?.name || (shared.map.basemap?.item?.title == nil && basemap.title == "Basemap")) {
                                    Color.cyan.opacity(0.25)
                                }
                                HStack {
                                    AsyncImage(url: basemap.thumbnail?.url, scale: 1) { image in
                                        image
                                    } placeholder: {
                                        ProgressView()
                                        
                                    }
                                    Text(basemap.title)
                                    Spacer()
                                }
                                .onTapGesture {
                                    Task {
                                        //UserDefaults().removeObject(forKey: "basemap")
                                        //UserDefaults.standard.set(basemap.id?.rawValue, forKey: "basemap")
                                        //shared.map.basemap = Basemap(item: basemap)
                                        if (model.selected == "Images") {
                                            
                                            let map: Map = Map(
                                                item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: basemap.id!)
                                            )
                                            try await map.load()

                                            let reference = map.basemap?.referenceLayers.first
                                            let raster = map.basemap?.baseLayers.filter({ layer in
                                                return (layer as? RasterLayer) != nil
                                            }).first
                                            let tiled = map.basemap?.baseLayers.filter({ layer in
                                                return (layer as? ImageTiledLayer) != nil
                                            }).first
                                            if (tiled?.spatialReference?.wkid != shared.map.spatialReference?.wkid) {
                                                if (raster?.item != nil) {
                                                    let newRaster = RasterLayer(item: (raster?.item)!)
                                                    //raster?.maxScale = 1000000
                                                    raster?.minScale = nil
                                                    let newBasemap = Basemap(baseLayer: newRaster.clone())
                                                    newBasemap.addReferenceLayer(reference!.clone())
                                                    newBasemap.name = basemap.title
                                                    shared.map.basemap = newBasemap
                                                    UserDefaults.standard.set(newBasemap.toJSON(), forKey: "basemap")


                                                }
                                            } else {
                                                shared.map.basemap = Basemap(item: basemap)
                                                UserDefaults.standard.set(basemap.toJSON(), forKey: "basemap")

                                            }

                                        } else {
                                            shared.map.basemap = Basemap(item: basemap)
                                            UserDefaults.standard.set(basemap.toJSON(), forKey: "basemap")

                                        }
                                        self.presentationMode.wrappedValue.dismiss()
                                    }

                                }
                            }
                            .frame( minHeight: 130)

                            Spacer()
    
                            
                        }
                    }

                }
                Picker("", selection: $model.selected) {
                    Text("Maps").tag("Maps")
                    Text("Images").tag("Images")
                    Text("Esri").tag("Esri")
                }
                .pickerStyle(.segmented)
                .onReceive(model.$selected) { value in
                    Task {
                        do {
                            var query = "id: f6329364e80c438a958ce74aadc3a89f"

                            if (value == "Maps") {
                                query = "id: f6329364e80c438a958ce74aadc3a89f"
                            } else if (value == "Images") {
                                query = "id: 492386759d264d49948bf7f83957ddb9"
                            } else if (value == "Esri") {
                                query = "id: 5e4b1873eeed4e448aca4bf930df0cd0"
                            }
                            await getGroups(for: query) {
                                groups in
                                if (groups.results.count > 0) {
                                    let group = groups.results.first
                                    if (group != nil) {
                                        
                                        Task {
                                            do {
                                                await getMaps(for: group?.id.rawValue) {
                                                    maps in
                                   
                                                    if (model.selected == "Images") {
                                                        basemaps = maps.results.sorted{$0.title > $1.title}
                                                    } else {
                                                        basemaps = maps.results.sorted{$0.title < $1.title}
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                }
                .toolbar {
                    Button("Close") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .navigationViewStyle(.stack)

            }.padding()

        }
    //}
}

func getGroups(for query: String, completion: @escaping (PortalQueryResultSet<PortalGroup>)  -> Void) async {
    do {
        let portal: Portal = .arcGISOnline(connection: .anonymous)
        let groups = try await portal.findGroups(queryParameters: PortalQueryParameters(query: query))
        completion(groups)
          
    } catch {
        
    }
}

func getMaps(for id: String!, completion: @escaping (PortalQueryResultSet<PortalItem>)  -> Void) async {
    do {
        let portal: Portal = .arcGISOnline(connection: .anonymous)
        var params = PortalQueryParameters(query: "type: Web Map AND group: "+id)
        params.limit = 30
        let maps =  try await portal.findItems(queryParameters: params)

       completion(maps)
          
    } catch {
        print(error)
    }
}


struct BasemapView_Previews: PreviewProvider {
    static var previews: some View {
        BasemapView()
    }
}
