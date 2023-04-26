//
//  InfoView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/13/23.
//

import SwiftUI
import ArcGIS 
struct InfoView: View {
    @State var feature: Feature?
    @State  var deed: [String:Any]? = [:]
    @State  var photos: [[String:Any]] = []
    @State var fromSearch: Bool
    @EnvironmentObject  var shared: SharedData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ScrollView {
            VStack {
                Text(feature!.attributes["SITE_ADDRESS"] as? String ?? "")
                    .font(.largeTitle)
                PropertyLinksView(feature: feature, siteAddress: feature?.attributes["SITE_ADDRESS"] as? String)
                GeneralView(attributes: feature!.attributes)
                OwnerView(attributes: feature!.attributes)
                ValuationView(attributes: feature!.attributes)
                SaleView(attributes: feature!.attributes)
                DeedView(attributes: feature!.attributes, deed: deed ?? [:])
                BuildingView(attributes:feature!.attributes)
                PhotoViews(photos: photos)
                    .onAppear{
                        Task {
                            let details: PropertyDetails = await getPropertyDetails(feature: feature, fromSearch: self.fromSearch, viewpoint: shared.viewpoint!, table: shared.table as! ServiceFeatureTable, graphics: shared.graphics, map: shared.map, proxy: shared.proxy!)
                            self.photos = details.photos
                            self.deed = details.deed
                        }
                    }
            }
        }
        .toolbar {
            if (!fromSearch) {
                Button("Close") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct InfoView_Previews: PreviewProvider {

    static var previews: some View {
        InfoView(fromSearch: false)
  
    }
}
