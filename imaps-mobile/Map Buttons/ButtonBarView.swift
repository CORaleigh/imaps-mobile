import SwiftUI

struct ButtonBarView: View {
    @StateObject var panelVM: PanelViewModel
    var body: some View {
        VStack (spacing: 0) {
            Button {
                if panelVM.selectedPanel == .search {
                    panelVM.isPresented.toggle()
                } else {
                    panelVM.isPresented = true
                }
                panelVM.selectedPanel = .search
            }
        label: {
            Image(systemName: "magnifyingglass")
                .padding(.horizontal, 15)
            
                .padding(.vertical, 15)
                .background(Color(UIColor.tertiarySystemBackground))
                .foregroundColor(.secondary)
                .clipShape(
                    .rect(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 8
                    )
                )
        }.padding(.top, 10).padding(.trailing, 10).padding(.bottom, 0)
                .buttonStyle(.plain)
            
            Button {
                if panelVM.selectedPanel == .layers {
                    panelVM.isPresented.toggle()
                } else {
                    panelVM.isPresented = true
                }
                panelVM.selectedPanel = .layers
            }
        label: {
            Image(systemName: "square.3.layers.3d")
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background(Color(UIColor.tertiarySystemBackground))
                .foregroundColor(.secondary)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )
        }.padding(.trailing, 10).padding(.top, 0)
                .buttonStyle(.plain)
            
            Button {
                if panelVM.selectedPanel == .basemap {
                    panelVM.isPresented.toggle()
                } else {
                    panelVM.isPresented = true
                }
                panelVM.selectedPanel = .basemap
            }
        label: {
            Image(systemName: "map")
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background(Color(UIColor.tertiarySystemBackground))
                .foregroundColor(.secondary)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 0
                    )
                )
        }.padding(.top, 0).padding(.trailing, 10)
                .buttonStyle(.plain)
            
        }.shadow(color: .gray, radius: 2, x: 0, y: 2)
    }
}

#Preview {
    ButtonBarView(panelVM: PanelViewModel(isPresented: false))
}
