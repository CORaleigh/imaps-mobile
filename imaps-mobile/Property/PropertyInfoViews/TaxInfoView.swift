import SwiftUI
import ArcGIS

struct TaxInfoView: View {
    @ObservedObject var panelVM: PanelViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    let attributes: [String : Any]
    var body: some View {
        Button {
            self.isActive = true
        } label: {
            HStack {
                Image(systemName: "doc")
                Text("Tax Info")
                
            } .frame(maxWidth: .infinity)
                .navigationDestination(isPresented: $isActive) {
                    let city = (attributes["CITY_DECODE"] as? String) ?? ""
                    
                    if let reid = attributes["REID"] as? String {
                        if let url = URL(string: getUrlString(city: city, reid: reid)) {
                            WebView(request: URLRequest(url: url))
                                .navigationTitle("Tax Info")
                        }
                    }
                }
        }
        .padding(.horizontal, 10)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .onReceive(panelVM.$selectedPinNum) { selectedPinNum in
            self.isActive = false
        }
    }
}


func getUrlString(city: String, reid: String) -> String {
    var urlString = "https://services.wake.gov/realestate/Account.asp?id=\(reid)"
    if city.contains("DURHAM COUNTY") {
        urlString = "https://taxcama.dconc.gov/camapwa/PropertySummary.aspx?REID=\(reid)"
    }
    return urlString
}
