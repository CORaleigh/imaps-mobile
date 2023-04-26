//
//  SearchHistoryView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/23/23.
//

import SwiftUI
import ArcGIS
struct SearchHistoryView: View {
    @State var history: SearchHistory = SearchHistory(historyItems: [])
    @EnvironmentObject var shared: SharedData

    var body: some View {
        List {
            ForEach(history.historyItems.reversed(), id:\.self) { item in
                NavigationLink(item.value) {
                    PropertyInfoView(value: ListValue(id: UUID(), objectid: 0, value: item.value, field: item.field, table: shared.table! as! ServiceFeatureTable), source: "history")
                        .environmentObject(shared)
                }
            }
        }
        .onAppear {
            self.history = getSearchHistory()
        }
        .navigationTitle("Search History")
    }
}

struct SearchHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SearchHistoryView()
    }
}
