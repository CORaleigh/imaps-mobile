//
//  MapPopupView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/24/23.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct MapPopupView: View {
    @State  var popup: Popup?
    @State  var identifyResultCount: Int
    @State  var identifyResultIndex = 0
    @State  var identifyResults:[IdentifyLayerResult]?
    @State  var showPopup: Bool

    var body: some View {
        
        VStack {
            if (identifyResultCount > 1) {
                HStack{
                    Button {
                        if (identifyResultIndex == 0) {
                            identifyResultIndex = identifyResultCount - 1
                        } else {
                            identifyResultIndex -= 1
                        }
                        self.popup = identifyResults![identifyResultIndex].popups.first
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                    }
                    Text(String(identifyResultIndex+1)+" of "+String(identifyResultCount))
                    Button {
                        if (identifyResultIndex == identifyResultCount - 1) {
                            identifyResultIndex = 0
                        } else {
                            identifyResultIndex += 1
                        }
                        self.popup = identifyResults![identifyResultIndex].popups.first
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                    }
                }
            }
            if let popup = popup {
                PopupView(popup: popup, isPresented: $showPopup).showCloseButton(true)
            }
        }
    }
}

//struct MapPopupView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapPopupView()
//    }
//}
