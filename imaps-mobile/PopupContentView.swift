import SwiftUI
import ArcGIS
import ArcGISToolkit

struct PopupContentView: View {
    @ObservedObject  var popupVM: PopupViewModel
    @State var popup: Popup?
    var body: some View {
        NavigationStack {
            VStack {
                if (popupVM.identifyResultCount > 1) {
                    HStack {
                        Button {
                            popupVM.identifyResultIndex = (popupVM.identifyResultIndex == 0) ? (popupVM.identifyResultCount - 1) : (popupVM.identifyResultIndex - 1)
                            if let popup = popupVM.identifyResults?[popupVM.identifyResultIndex].popups.first {
                                popupVM.popup = popup
                            }
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                        }

                        Text("\(popupVM.identifyResultIndex + 1) of \(popupVM.identifyResultCount)")

                        Button {
                            popupVM.identifyResultIndex = (popupVM.identifyResultIndex == popupVM.identifyResultCount - 1) ? 0 : (popupVM.identifyResultIndex + 1)
                            if let popup = popupVM.identifyResults?[popupVM.identifyResultIndex].popups.first {
                                popupVM.popup = popup
                            }
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                        }
                    }
                }
                if let popup = popupVM.popup {
                    PopupView(popup: popup, isPresented: $popupVM.isPresented)
                        .showCloseButton(false)
                        .padding()
                }

                
            }.padding(.all)
                .toolbar {
                    ToolbarItem (placement: .navigationBarTrailing){
                        Button(action: {
                            self.popupVM.dismiss()
                        },label: {
                            Image(systemName: "xmark")
                        })
                    }
                    
                }
        }
        
    }
}

//#Preview {
//    PopupContentView()
//}
