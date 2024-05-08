import SwiftUI
import ArcGIS

struct PropertyListView: View, Equatable {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var panelVM: PanelViewModel
    
    @ObservedObject var propertyVM: PropertyViewModel
    @State var fromSearch: Bool
    static func == (lhs: PropertyListView, rhs: PropertyListView) -> Bool {
        return true
    }
    
    var body: some View {
        List {
            ForEach(0..<propertyVM.features.count, id:\.self) { i in
                let feature: PropertyFeature = propertyVM.features[i]
                VStack {
                    PropertyListItemView(feature: feature, mapViewModel: mapViewModel, panelVM: panelVM)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("Background"))
        .navigationTitle("Property List")
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
        .onReceive(panelVM.$selectedPinNum) { selectedPinNum in
            propertyVM.features.forEach { feature in
                feature.isPresented = false
            }
            mapViewModel.graphics.removeAllGraphics()

        }
        .onReceive(propertyVM.$features) { features in
            propertyVM.features.forEach { feature in
                feature.isPresented = false
            }
        }
    }
    
    
    
    
}

//struct PropertyListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyListView()
//    }
//}


struct PropertyListItemView: View {
    @StateObject var feature: PropertyFeature
    let mapViewModel: MapViewModel
    let panelVM: PanelViewModel
    var body: some View {
        Button {
            feature.isPresented = true
        }
        label: {
            VStack (alignment: .leading) {
                let address = (feature.feature.attributes["SITE_ADDRESS"] as? String ?? "") + " " + (feature.feature.attributes["STMISC"] as? String ?? "")
                let owner = (feature.feature.attributes["OWNER"] as? String ?? "")
                Text(address)
                Text(owner)
            }
        }
        .navigationDestination(isPresented: $feature.isPresented) {
            PropertyInfoView(mapViewModel: mapViewModel, panelVM: panelVM, feature: FeatureViewModel(feature: feature.feature))
            //                    NavigationLink(destination: {PropertyInfoView(mapViewModel: mapViewModel, panelVM: panelVM, feature:
            //                    }).isDetailLink(false)
        }
        .buttonStyle(.plain)
    }
}
