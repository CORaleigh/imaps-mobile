import SwiftUI
import ArcGIS
struct SearchHistoryView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    @State var searchHistory: SearchHistoryModel
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                
                Text("Recent").font(.headline)
                Divider()
                    .frame(height: 1)
                ScrollView {
                        VStack (alignment: .leading) {
                            ForEach(searchHistory.history.historyItems.reversed(), id:\.self) { item in
                                let viewModel: ViewModel = ViewModel(text: item.value)
                                
                                NavigationLink(destination: {
                                    PropertyView(viewModel: viewModel, group: SearchGroup(field: item.field, alias: item.field, features: []), source: .history, mapViewModel: mapViewModel, panelVM: panelVM)
                                }, label: {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        Text(item.value)
                                        
                                        Spacer()
                                        
                                    }
                                    .background(Color("Background").opacity(0.01))
                                    
                                })
                                
                                .foregroundColor(Color.primary)
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)

                                
                                Divider()
                            }
                            Spacer()
                        }

                }
                
            }        .padding()
        }
    }
}

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct SearchHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SearchHistoryView(
            mapViewModel: MapViewModel(
                map: Map (
                    item: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("95092428774c4b1fb6a3b6f5fed9fbc4")!)
                )
            ), panelVM: PanelViewModel(isPresented: false),
            searchHistory: SearchHistoryModel(history: SearchHistory(historyItems: [])))
    }
}
