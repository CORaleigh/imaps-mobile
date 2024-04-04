import SwiftUI
import ArcGIS
struct SearchHistoryView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var panelVM: PanelViewModel

    @State var history: SearchHistory
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {

                Text("Recent").font(.headline)
                Divider()
                    .frame(height: 1)
                ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(history.historyItems.reversed(), id:\.self) { item in
                            let viewModel: ViewModel = ViewModel(text: item.value)
                            
                            NavigationLink(destination: {
                                PropertyView(viewModel: viewModel, group: SearchGroup(field: item.field, alias: item.field, features: []), source: .history)
                                    .environmentObject(mapViewModel)
                                    .environmentObject(panelVM)
                            }, label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text(item.value)
                                }
                            })
                            .foregroundColor(Color.primary)
                            .buttonStyle(FlatLinkStyle())
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
        SearchHistoryView(history: SearchHistory(historyItems: []))
    }
}
