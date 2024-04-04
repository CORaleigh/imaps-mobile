import SwiftUI
import ArcGIS

struct TaxInfoView: View {
    let attributes: [String : Any]
    var body: some View {
        NavigationLink(destination: {
            let city = (attributes["CITY_DECODE"] as? String) ?? ""
            
            if city.contains("DURHAM COUNTY") {
                WebView(request: URLRequest(url: URL(string: "https://taxcama.dconc.gov/camapwa/PropertySummary.aspx?REID=\(attributes["REID"] ?? "")")!))
                    .navigationTitle("Tax Info")
            } else {
                WebView(request: URLRequest(url: URL(string: "https://services.wake.gov/realestate/Account.asp?id=\(attributes["REID"] ?? "")")!))
                    .navigationTitle("Tax Info")
            }
        },          
                       label: {
            HStack {
                Image(systemName: "doc")
                Text("Tax Info")
                
            } .frame(maxWidth: .infinity)
            
            
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}
