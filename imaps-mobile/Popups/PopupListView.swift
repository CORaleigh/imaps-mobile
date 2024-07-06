//
//  PopupListView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 5/22/24.
//

import SwiftUI
import ArcGIS

struct PopupListView: View {
    @ObservedObject  var popupVM: PopupViewModel
    @State private var isExpanded: [Bool]
    init(popupVM: PopupViewModel) {
        self.popupVM = popupVM
        // Initialize the array with true values (expanded state) for each group
        self._isExpanded = State(initialValue: Array(repeating: true, count: popupVM.identifyResults.count))
    }
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach($popupVM.identifyResults.indices, id:\.self) { index in
                        if let result = popupVM.identifyResults[safe: index] {
                            
                            DisclosureGroup(isExpanded: $isExpanded[index]) {
                                ForEach(0..<result.popups.count, id:\.self) { i in
                                    if let popup = result.popups[safe: i]
                                    {
                                        let geoElement = result.geoElements[safe: i]
                                        let layer = result.layerContent as? FeatureLayer ?? nil
                                        let layerName = result.layerContent.name
                                        if let geoElement = geoElement{
                                            
                                            Text(popup.title)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .contentShape(Rectangle()) // Make the entire row clickable
                                                .onTapGesture {
                                                    popupVM.popup = popup
                                                    popupVM.geoElement = geoElement
                                                    popupVM.layer = layer
                                                    popupVM.layerName = layerName
                                                }
                                        } else {
                                            // Show title even when geoElement is nil
                                            Text(popup.title)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    popupVM.popup = popup
                                                    popupVM.geoElement = nil
                                                    popupVM.layer = layer
                                                    popupVM.layerName = layerName


                                                }
                                        }
                                    }
                                }
                                }
                             label: {
                                
                                 Text("\(result.layerContent.name) (\(result.popups.count))")
                                
                            }
                             .contentShape(Rectangle())

                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing){
                    Button(action: {
//                        if (lastLayer != nil) {
//                            lastLayer?.clearSelection()
//                        }
                        self.popupVM.popup = nil
                        self.popupVM.dismiss()
                    },label: {
                        
                        Image(systemName: "xmark")
                        
                    })
                }
            }
            .navigationTitle("\(popupVM.popupCount) Features").navigationBarTitleDisplayMode(.inline)

        }
    }
 
}

//#Preview {
//    PopupListView(popupVM: PopupViewModel(isPresented: <#T##Bool#>))
//}
