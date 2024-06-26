import SwiftUI
import ArcGIS

struct SearchView: View, Equatable {
    @StateObject private var searchListVM = SearchListViewModel()
    @StateObject var mapViewModel: MapViewModel
    @StateObject var panelVM: PanelViewModel
    
    @State private var searchText: String = ""
    @State private var propertySelected: Bool = false
    @State private var searchHistory: SearchHistoryModel = SearchHistoryModel(history: getSearchHistory())
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
                                        SearchItemView(mapViewModel: self.mapViewModel, panelVM: self.panelVM,text: text, group: group)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color("Background"))
                    .scrollContentBackground(.hidden)
                    .frame(height: searchText.count > 0 ? nil : 5)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by address, owner, PIN or REID")
                    
                    .onChange(of: searchText) { value in
                        searchListVM.handleSearchTextChange(value)
                    }

                    .onChange(of: propertySelected) { selected in
                        if selected == false {
                            self.panelVM.selectedPinNum = ""
                            self.mapViewModel.graphics.removeAllGraphics()
                            searchHistory.history = getSearchHistory()
                        }
                    }

                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    if searchText.count == 0 && self.panelVM.selectedFloatingPanelDetent != .summary && self.panelVM.selectedDetent != .bar {
                        SearchHistoryView(mapViewModel: self.mapViewModel, panelVM: self.panelVM, searchHistory: searchHistory)
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

            .toolbarBackground(.visible)
            .toolbarBackground(Color("Background").opacity(0.5))
            .navigationDestination(isPresented: $propertySelected) {
                PropertyView(viewModel: ViewModel(text: self.panelVM.selectedPinNum), group: SearchGroup(field: "PIN_NUM", alias: "PIN", features: []), source: .map, mapViewModel: mapViewModel, panelVM: panelVM)
            }

            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
        }
        .navigationViewStyle(.stack)

        
    }
    
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(mapViewModel: MapViewModel(), panelVM: PanelViewModel(isPresented: false))
        
    }
}


