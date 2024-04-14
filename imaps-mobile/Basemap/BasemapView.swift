import SwiftUI
import ArcGIS

struct BasemapView: View, Equatable {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    @ObservedObject  var basemapVM: BasemapViewModel
    @State var basemaps: [PortalItem] = [];
    @State var selectedItem: BasemapType?
    static func == (lhs: BasemapView, rhs: BasemapView) -> Bool {
        return lhs.basemapVM.inRaleigh == rhs.basemapVM.inRaleigh
    }
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid (columns: [
                        GridItem(.flexible(), spacing: 20, alignment: .center),
                        GridItem(.flexible(), spacing: 20, alignment: .center)
                    ]) {
                        
                        ForEach(basemaps.filter{
                            basemapVM.selected != .Images || ((basemapVM.selected == .Images && basemapVM.inRaleigh  || (!basemapVM.inRaleigh && ($0 as Item).tags.contains("countywide"))))
                        }, id: \.self.title) { basemap in
                            ZStack {
                                BasemapItemView(basemap: basemap)
                                    .onTapGesture {
                                        Task {
                                            if (basemapVM.selected == .Images) {
                                                
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
                                                if (tiled?.spatialReference?.wkid != mapViewModel.map.spatialReference?.wkid) {
                                                    if (raster?.item != nil) {
                                                        
                                                        let newRaster = RasterLayer(item: (raster?.item)!)
                                                        newRaster.maxScale = nil
                                                        newRaster.minScale = nil
                                                        let newBasemap = Basemap(baseLayer: newRaster.clone())
                                                        if reference != nil {
                                                            newBasemap.addReferenceLayer(reference!.clone())
                                                        }
                                                        newBasemap.name = basemap.title
                                                        mapViewModel.map.basemap = newBasemap
                                                        UserDefaults.standard.set(newBasemap.toJSON(), forKey: "basemap")
                                                        
                                                        
                                                    }
                                                } else {
                                                    mapViewModel.map.basemap = Basemap(item: basemap)
                                                    UserDefaults.standard.set(basemap.toJSON(), forKey: "basemap")
                                                    
                                                }
                                                
                                            } else {
                                                mapViewModel.map.basemap = Basemap(item: basemap)
                                                UserDefaults.standard.set(basemap.toJSON(), forKey: "basemap")
                                                
                                            }
                                            basemapVM.updateView()
                                        }
                                    }
                                
                                if (basemap.title == mapViewModel.map.basemap?.item?.title || basemap.title == mapViewModel.map.basemap?.name || (mapViewModel.map.basemap?.item?.title == nil && basemap.title == "Basemap")) {
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.blue, lineWidth: 4)
                                }
                                
                            }
                        }
                    }.padding(.all)
                }
                Picker("", selection: $basemapVM.selected) {
                    ForEach(BasemapType.allCases, id: \.self) { type in
                        Text(String(describing: type))
                    }
                }
                .pickerStyle(.segmented)
                
                .onAppear {
                    
                    UIScrollView.appearance().backgroundColor = UIColor(Color("Background"))
                    
                    let boundary = Boundary().boundary
                    self.basemapVM.objectWillChange.send()
                    
                    self.basemapVM.inRaleigh = GeometryEngine.isGeometry(basemapVM.center, intersecting: boundary)
                }
                .onChange(of: basemapVM.center) { center in
                    let boundary = Boundary().boundary
                    self.basemapVM.objectWillChange.send()
                    
                    self.basemapVM.inRaleigh = GeometryEngine.isGeometry(center, intersecting: boundary)
                }
                
                .onReceive(basemapVM.$selected) { value in
                    Task {
                        do {
                            var query = "id: f6329364e80c438a958ce74aadc3a89f"
                            if (value == .Maps) {
                                query = "id: f6329364e80c438a958ce74aadc3a89f"
                            } else if (value == .Images) {
                                query = "id: 492386759d264d49948bf7f83957ddb9"
                            } else if (value == .Esri) {
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
                                                    
                                                    if (basemapVM.selected == .Images) {
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
            .navigationTitle("Basemaps")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
}

struct BasemapView_Previews: PreviewProvider {
    static var previews: some View {
        BasemapView(mapViewModel: MapViewModel(
            map: Map (
                item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
            )
        ), panelVM: PanelViewModel(isPresented: false), basemapVM: BasemapViewModel(selected: .Maps, center: Point(latitude: 0, longitude: 0)))
    }
}
