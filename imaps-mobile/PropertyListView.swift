//
//  PropertyListView.swift
//  layout-test
//
//  Created by Greco, Justin on 4/26/23.
//

import SwiftUI
import ArcGIS

struct PropertyListView: View {
    @State var features: [Feature]
    @State var fromSearch: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(0..<features.count, id:\.self) { i in
                    let feature: Feature = features[i]
                    VStack {
                        NavigationLink(destination: {PropertyInfoView(feature: feature, fromSearch: fromSearch)}, label: {
                            VStack (alignment: .leading) {
                                Text(feature.attributes["SITE_ADDRESS"] as! String)
                                Text(feature.attributes["OWNER"] as! String)
                            }
                        })
                    }
                }
            }
            .navigationTitle("Property List")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)

    }
}

//struct PropertyListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyListView()
//    }
//}
