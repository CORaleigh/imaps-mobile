//
//  SearchItemView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/26/23.
//

import SwiftUI

struct SearchItemView: View {
    @EnvironmentObject var dataModel: MapDataModel

    @State var text: String
    @State var group: SearchGroup
    var body: some View {
        NavigationLink(text) {
            PropertyView(viewModel: ViewModel(text: text), group: group, source: .search)
                .environmentObject(self.dataModel)
        }
    }
}
//
//struct SearchItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchItemView()
//    }
//}
