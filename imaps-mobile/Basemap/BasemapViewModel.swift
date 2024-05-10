import Foundation
import ArcGIS

enum BasemapType: CaseIterable {
    case Maps, Images, Esri
}

class BasemapViewModel: ObservableObject {
    @Published var selected: BasemapType
    @Published var center: Point
    @Published var inRaleigh: Bool = true
    init(selected: BasemapType, center: Point) {
        self.selected = selected
        self.center = center
    }
    func updateView(){
        self.objectWillChange.send()
    }
}

func getGroups(for query: String, completion: @escaping (PortalQueryResultSet<PortalGroup>)  -> Void) async {
    do {
        let portal: Portal = .arcGISOnline(connection: .anonymous)
        let groups = try await portal.findGroups(queryParameters: PortalQueryParameters(query: query))
        completion(groups)
        
    } catch {
        
    }
}

func getMaps(for id: String, completion: @escaping (PortalQueryResultSet<PortalItem>)  -> Void) async {
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
