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
                    HStack{
                        Button {
                            if (popupVM.identifyResultIndex == 0) {
                                popupVM.identifyResultIndex = popupVM.identifyResultCount - 1
                            } else {
                                popupVM.identifyResultIndex -= 1
                            }
                            self.popupVM.popup = popupVM.identifyResults![popupVM.identifyResultIndex].popups.first
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                        }
                        Text(String(popupVM.identifyResultIndex+1)+" of "+String(popupVM.identifyResultCount))
                        Button {
                            if (popupVM.identifyResultIndex == popupVM.identifyResultCount - 1) {
                                popupVM.identifyResultIndex = 0
                            } else {
                                popupVM.identifyResultIndex += 1
                            }
                            
                            self.popupVM.popup = popupVM.identifyResults?[popupVM.identifyResultIndex].popups.first
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                        }
                    }
                }
                if popupVM.popup != nil {
                    PopupView(popup: popupVM.popup!, isPresented: $popupVM.isPresented).showCloseButton(false)
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
