//
//  SearchView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var shared: SharedData
    @StateObject var viewModel: SearchViewModel = SearchViewModel();
    @FocusState private var focused: Bool
    @StateObject var searchSources = SearchSources(sources: [])
    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    var body: some View {
        NavigationView {
            NavigationStack {
                VStack(alignment: .leading) {
                    HStack {
                        TextField("Search", text: $viewModel.searchableText)
                                .focused($focused)
                                .textFieldStyle(.roundedBorder)
                                .frame(alignment: .top)
                                .autocorrectionDisabled()
                                .onReceive(viewModel.$searchableText.debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)) {
                                    if $0.count > 3 {
                                        for source in self.searchSources.sources {
                                            let params = QueryParameters()
                                            params.returnsGeometry = false
                                            params.addOrderByField(OrderBy(fieldName: source.fieldName, sortOrder: OrderBy.SortOrder.ascending))
                                            
                                            source.objectWillChange.send()
                                            source.values.removeAll()
                                            search(for: source, params: params, newValue: $0)
                                        }
                                    } else {
                                        clearSearch()
                                        for source in self.searchSources.sources {
                                            source.objectWillChange.send();
                                            source.values.removeAll();
                                        }
                                    }
                                }

                                .onAppear {
                                    focused = true
                                    //clearSearch()
                                    Task {
                                        do {
                                            if (searchSources.sources.count == 0) {
                                                await  getSearchSources(for: shared.map) {
                                                    sources in
                                                    for source in sources {
                                                        searchSources.sources.append(source)
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                

                        }
                        NavigationLink(destination: {SearchHistoryView()}, label: {
                            Image(systemName: "clock")

                        })
                        
                    } .padding()
                      .background(Color.gray.opacity(0.4))
                      .environmentObject(shared)


                    
                    List {
                        ForEach(searchSources.sources) { source in
                            if source.values.count > 0 {
                                SearchListView(parentPresentation: presentationMode, source: source,  clearSearch: self.clearSearch)
                                    .environmentObject(shared)
                            }
                        }
                    }.listStyle(.grouped)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Search").font(.headline)
                            Text("by address, owner, PIN, REID or street").font(.caption)
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Close") {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }

                }
            }
            .navigationTitle("Search")
            .navigationBarHidden(true)


        }
        .navigationViewStyle(.stack)

        .environmentObject(shared)
    }
    func clearSearch() {
        self.searchSources.objectWillChange.send()
        for source in self.searchSources.sources {
            source.objectWillChange.send();
            source.values.removeAll()
        }
    }
}

class SearchViewModel: NSObject, ObservableObject {
    @Published var searchableText = ""
}

@MainActor func getSearchSources(for map: Map, completion: @escaping ([SearchSource])  -> Void) async {
    var searchSources: [SearchSource] = []
    var tablesLoaded = 0
    do {
        try await map.load()
        for table in map.tables {
            do {
                try await table.load()
                if table.tableName.contains("Condos") {
                    searchSources.append(SearchSource(table: table as! ServiceFeatureTable, fieldName: "SITE_ADDRESS", alias: "Address", values:[]))
                    searchSources.append(SearchSource(table: table as! ServiceFeatureTable, fieldName: "PIN_NUM", alias: "PIN", values:[]))
                    searchSources.append(SearchSource(table: table as! ServiceFeatureTable, fieldName: "REID", alias: "REID", values:[]))
                    searchSources.append(SearchSource(table: table as! ServiceFeatureTable, fieldName: "OWNER", alias: "Owner", values:[]))
                    searchSources.append(SearchSource(table: table as! ServiceFeatureTable, fieldName: "FULL_STREET_NAME", alias: "Street", values:[]))
                }
                
                tablesLoaded += 1
                if tablesLoaded == map.tables.count {
                    completion(searchSources)
                }
            } catch {
                
            }
        }
    } catch {
        
    }
}

struct QueryResults: Codable {
    var features: [QueryFeature]
}

struct QueryFeature: Codable {
    var attributes: [String: String]
}

func search(for source: SearchSource, params: QueryParameters, newValue: String) {
    @State  var task: Task<Void, Never>?
    guard !newValue.isEmpty else { 
        source.values = []
        task?.cancel()
        return
    }
    // task?.cancel()
    DispatchQueue.main.async {
        task = Task {
    //            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000.0))
    //            guard !Task.isCancelled else {
    //                return
    //            }
            params.whereClause = source.fieldName + " LIKE  '"+newValue.uppercased()+"%'"
            params.maxFeatures = 10
            let urlString = "https://maps.raleighnc.gov/arcgis/rest/services/Property/Property/FeatureServer/1/query?where=\(source.fieldName)+LIKE+ '\(newValue.uppercased())%'&outFields=\(source.fieldName)&returnGeometry=false&returnDistinctValues=true&orderByFields=\(source.fieldName)&f=json".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)


            let url = URL(string: urlString!)!
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    var list: [ListValue] = []
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(QueryResults.self, from: data)
                        product.features.forEach{ feature in
                            let listValue = ListValue(
                                id: UUID(),
                                objectid: 0,//feature.attributes["OBJECTID"] as! Int64,
                                value: feature.attributes[source.fieldName]!,
                                field: source.fieldName,
                                table: source.table
                            )
                            listValue.objectWillChange.send()
                            list.append(listValue)
                        }
                    } catch {
                        
                    }
                    
                    source.objectWillChange.send()
                    source.values = list
                }

            })

            task.resume()
//            let result = try? await source.table.queryFeatures(using: params)
//            var list: [ListValue] = []
//            if result != nil {
//                result?.features().forEach({feature in
//                    let listValue = ListValue(
//                        id: UUID(),
//                        objectid: feature.attributes["OBJECTID"] as! Int64,
//                        value: feature.attributes[source.fieldName] as! String,
//                        field: source.fieldName,
//                        table: source.table
//                    )
//                    listValue.objectWillChange.send()
//                    list.append(listValue)
//                })
//                source.objectWillChange.send()
//                source.values = list
//
//                print(source.values.count)
//            }
       }
    }
}



struct SearchListView: View {
    @EnvironmentObject var shared: SharedData
    let parentPresentation: Binding<PresentationMode>
    @ObservedObject var source:SearchSource
    @State private var task: Task<Void, Never>?
    var clearSearch: () -> Void
    var body: some View {
        Section(header: Text(source.alias)) {
            ForEach(source.values, id: \.id) { value in
                NavigationLink(value.value) {
                    PropertyInfoView(value: value, source: "search")
                        .environmentObject(shared)
                }
            }
        }
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//            .environmentObject(SharedData())
//    }
//}
