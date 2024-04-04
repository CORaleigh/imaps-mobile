import SwiftUI

struct SearchItemView: View {
    @EnvironmentObject var mapViewModel: MapViewModel

    @State var text: String
    @State var group: SearchGroup
    var body: some View {
        NavigationLink(text) {
            PropertyView(viewModel: ViewModel(text: text), group: group, source: .search)
                .environmentObject(self.mapViewModel)
        }
    }
}
//
//struct SearchItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchItemView()
//    }
//}
