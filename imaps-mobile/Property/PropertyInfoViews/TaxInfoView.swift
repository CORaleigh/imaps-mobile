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
                    
                    if city.contains("DURHAM COUNTY") {
                        WebView(request: URLRequest(url: URL(string: "https://taxcama.dconc.gov/camapwa/PropertySummary.aspx?REID=\(attributes["REID"] ?? "")")!))
                            .navigationTitle("Tax Info")
                    } else {
                        WebView(request: URLRequest(url: URL(string: "https://services.wake.gov/realestate/Account.asp?id=\(attributes["REID"] ?? "")")!))
                            .navigationTitle("Tax Info")
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
