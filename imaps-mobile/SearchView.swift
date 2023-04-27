//
//  SearchView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/25/23.
//

import SwiftUI
import ArcGIS
enum NetworkError: Error {
    case badURL
    case badID
}

class Search: ObservableObject {
    @Published var searchableText = ""
    @Published var results: [SearchFeature] = [SearchFeature]()
    @Published var fetching =  false
    func getData(searchTerm: String, field: String) async throws -> [SearchFeature] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.raleighnc.gov"
        components.path = "/arcgis/rest/services/Property/Property/FeatureServer/1/query"
        components.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "\(field) LIKE '\(searchTerm)%'"),
            URLQueryItem(name: "returnDistinctValues", value: "true"),
            URLQueryItem(name: "outFields", value: field),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "orderByFields", value: field),
            URLQueryItem(name: "maxRecordCount", value: "10")
        ]
        
        guard let url = components.url else {
            throw NetworkError.badID
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.badID
        }
        let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse?.features ?? []
    }
}
struct SearchResponse: Decodable {
    let features: [SearchFeature]
    enum CodingKeys: String, CodingKey {
        case features
    }
}
struct Attributes: Codable {
    let siteAddress: String?
    let fullStreetName: String?
    let owner: String?
    let reid: String?
    let pin: String?
    enum CodingKeys: String, CodingKey {
        case siteAddress = "SITE_ADDRESS"
        case fullStreetName = "FULL_STREET_NAME"
        case owner = "OWNER"
        case reid = "REID"
        case pin = "PIN"

    }
}
struct SearchFeature: Decodable {
    let attributes: Attributes
    enum CodingKeys: String, CodingKey {
        case attributes
    }
}
struct SearchView: View {
    @ObservedObject private var searchListVM = SearchListViewModel()
    @EnvironmentObject var dataModel: MapDataModel
    @EnvironmentObject var panelVM: PanelViewModel

    @State private var searchText: String = ""
    @State var searching: Bool = false

    var body: some View {
        NavigationView {
            NavigationStack {
                Spacer()

                VStack(alignment: .leading) {
                    List {
                        ForEach(searchListVM.groups, id:\.self) { group in
                            if group.features.count > 0 {
                                Section(header: Text(group.alias)) {
                                    ForEach(group.features, id: \.self) { feature in
                                        let text = feature.feature.attributes.siteAddress ?? feature.feature.attributes.fullStreetName ?? feature.feature.attributes.owner ?? feature.feature.attributes.reid ?? feature.feature.attributes.pin ?? ""
                                        SearchItemView(text: text, group: group)
                                            .environmentObject(self.dataModel)
                                    }
                                }
                            }
                        }
                    }
                    
                    .searchable(text: $searchText, placement: .navigationBarDrawer)
                    .onChange(of: searchText) { value in
                        Task {
                            searching = true
                            if !value.isEmpty && value.count > 3 {
                                try await Task.sleep(nanoseconds: 250_000_000)
                                guard !Task.isCancelled else {
                                    return
                                }
                                await searchListVM.search(text: value.uppercased())
                                searchListVM.updateView()
                            } else {
                                //searchListVM.groups.removeAll()
                                for group in searchListVM.groups {
                                    group.features.removeAll()

                                }
                                searchListVM.updateView()

                            }
                        }
                        
                    }
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)

                }

                
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem (placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            NavigationLink(destination: {
                                SearchHistoryView(history: getSearchHistory()).environmentObject(dataModel)}) {
                                    Image(systemName: "clock")
                                
                            }
                        }

            
                    }
                    ToolbarItem (placement: .navigationBarTrailing){
                        Button(action: {
                            self.panelVM.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }
                    
                }


            }
        }

        .navigationViewStyle(StackNavigationViewStyle())

    }
    
    
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView(mapDataModel: MapDataModel(map: nil))
//    }
//}
