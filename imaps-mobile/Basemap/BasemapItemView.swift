import SwiftUI
import ArcGIS
import ArcGISToolkit
struct BasemapItemView: View {
    @State var basemap: PortalItem
    var body: some View {
        VStack {
            if let thumbnailUrl = basemap.thumbnail?.url {
                AsyncImageView(url: thumbnailUrl)
                Text(basemap.title)
                Spacer()
            }
        }.frame(minHeight: 150)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
    }
}
