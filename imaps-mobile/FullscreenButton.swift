import SwiftUI

struct FullscreenButtonView: View {
    @ObservedObject var panelVM: PanelViewModel
    
    var body: some View {
        ToolbarItem(placement: .topBarTrailing) {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                Button(action: {
                    // Action to perform when the button is tapped
                    self.panelVM.fullScreen.toggle()
                    // You can also add additional actions here
                }) {
                    Image(systemName: self.panelVM.fullScreen == true ? "arrow.down.right.and.arrow.up.left.rectangle" : "arrow.down.backward.and.arrow.up.forward.rectangle")
                        .foregroundColor(.blue) // Customize the color as needed
                }
            }
        }
    }
}
