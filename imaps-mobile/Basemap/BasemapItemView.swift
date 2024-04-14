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


struct BasemapItemView_Previews: PreviewProvider {
    static var previews: some View {
        BasemapItemView(basemap: PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("02d50d24991747538e218e0a5806e9b3")!))
        
    }
}
