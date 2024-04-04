import SwiftUI
import ArcGIS

struct PropertyListView: View, Equatable {
    @EnvironmentObject var panelVM: PanelViewModel
    
    @State var features: [Feature]
    @State var fromSearch: Bool
    static func == (lhs: PropertyListView, rhs: PropertyListView) -> Bool {
        return true
    }
    
    var body: some View {
        List {
            ForEach(0..<features.count, id:\.self) { i in
                let feature: Feature = features[i]
                VStack {
                    NavigationLink(destination: {PropertyInfoView(feature: FeatureViewModel(feature: feature), fromSearch: fromSearch, fromList: false)}, label: {
                        VStack (alignment: .leading) {
                            Text(feature.attributes["SITE_ADDRESS"] as! String)
                            Text(feature.attributes["OWNER"] as! String)
                        }
                    }).isDetailLink(false)
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
    }
    
    
    
    
}

//struct PropertyListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyListView()
//    }
//}
