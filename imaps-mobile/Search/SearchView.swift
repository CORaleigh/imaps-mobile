import SwiftUI
import ArcGIS

struct SearchView: View, Equatable {
    @StateObject private var searchListVM = SearchListViewModel()
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var panelVM: PanelViewModel
    
    @State private var searchText: String = ""
    @State var searching: Bool = false
    @State private var propertySelected: Bool = false
    
    static func == (lhs: SearchView, rhs: SearchView) -> Bool {
        return true
    }
    
    var body: some View {
        NavigationStack {
            Spacer()
            ZStack {
                Color(uiColor: .tertiarySystemBackground).opacity(0.5).ignoresSafeArea(.all)
                VStack(alignment: .leading) {
                    List {
                        ForEach(searchListVM.groups, id:\.self) { group in
                            if group.features.count > 0 {
                                Section(header: Text(group.alias)) {
                                    ForEach(group.features, id: \.self) { feature in
                                        let text = feature.feature.attributes.siteAddress ?? feature.feature.attributes.fullStreetName ?? feature.feature.attributes.owner ?? feature.feature.attributes.reid ?? feature.feature.attributes.pin ?? ""
                                        SearchItemView(text: text, group: group)
                                            .environmentObject(self.mapViewModel)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: searchText.count > 0 ? .infinity : 5)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                                for group in searchListVM.groups {
                                    group.features.removeAll()
                                    
                                }
                                searchListVM.updateView()
                            }
                        }
                        
                    }
                    
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    if searchText.count == 0 && self.panelVM.selectedDetent != .summary {
                        SearchHistoryView(history: getSearchHistory())
                    }
                }
            }
            .onReceive (panelVM.$selectedPinNum) { selectedPinNum in
                self.propertySelected = selectedPinNum != ""
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing){
                    Button(action: {
                        self.panelVM.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                
            }
            .navigationDestination(isPresented: $propertySelected) {
                PropertyView(viewModel: ViewModel(text: self.panelVM.selectedPinNum), group: SearchGroup(field: "PIN_NUM", alias: "PIN", features: []), source: .map)
                    .environmentObject(mapViewModel)
                    .environmentObject(panelVM)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(MapViewModel(
                map: Map (
                    item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
                ),
                graphics: GraphicsOverlay(graphics: []),
                viewpoint: Viewpoint(latitude: 35.7796, longitude: -78.6382, scale: 500_000)
            ))
    }
}


