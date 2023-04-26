//
//  SearchHistoryView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/23/23.
//

import SwiftUI
import ArcGIS
struct SearchHistoryView: View {
    @EnvironmentObject var dataModel : MapDataModel

    @State var history: SearchHistory

    var body: some View {
        NavigationView {
            List {
                ForEach(history.historyItems.reversed(), id:\.self) { item in
                    let viewModel: ViewModel = ViewModel(text: item.value)
                    
                    NavigationLink(item.value) {
                        PropertyView(viewModel: viewModel, group: SearchGroup(field: item.field, alias: item.field, features: []), source: .history)
                            .environmentObject(dataModel)
                    }
                }
            }
            //        .onAppear {
            //            self.history = getSearchHistory()
            //        }
            .navigationTitle("Search History")
        }.navigationViewStyle(.stack)
    }
}

//struct SearchHistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchHistoryView(SearchHistory(historyItems: []))
//    }
//}
