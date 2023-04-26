//
//  PropertyLinksView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/17/23.
//

import SwiftUI
import ArcGIS
struct PropertyLinksView: View {
    @State  var feature: Feature?
    @State var siteAddress: String?
    var body: some View {
        Group {
            Grid() {
                GridRow {
//                    if (siteAddress != nil) {
//                        Link("Google Maps", destination: URL(string: "https://www.google.com/maps?q=\(self.siteAddress ?? "")")!)
//                
//                        .buttonStyle(.borderedProminent)
//                    }
                    if (feature?.attributes["REID"] != nil) {
                        NavigationLink(destination: {
                            WebView(request: URLRequest(url: URL(string: "https://services.wake.gov/realestate/Account.asp?id=\(feature?.attributes["REID"] ?? "")")!))
                                .navigationTitle("Tax Page")

                        },
                        label: {
                            Image(systemName: "house")
                            Text("Tax Page")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}

struct PropertyLinksView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyLinksView(siteAddress: "644 PIPER STREAM CIR")
    }
}
