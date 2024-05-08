import SwiftUI
import ArcGIS
import CoreLocation

struct LocationButtonView: View {
    @State var locationEnabled: Bool
    @State  var failedToStart: Bool
    @State var showAlert: Bool
    let locationDisplay: LocationDisplay
    
    var body: some View {
        ZStack {
            Button {
                locationEnabled.toggle()
                Task {
                    let locationManager = CLLocationManager()
                    if locationManager.authorizationStatus == .notDetermined {
                        locationManager.requestWhenInUseAuthorization()
                    }
                    
                    if locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .denied {
                        showAlert = true
                    }
                    do {
                        if (locationEnabled) {
                            try await locationDisplay.dataSource.start()
                            
                            locationDisplay.initialZoomScale = 40_000
                            locationDisplay.autoPanMode = .recenter
                        } else {
                            await  locationDisplay.dataSource.stop()
                        }
                        
                        
                    } catch {
                        
                        self.failedToStart = true
                        
                    }
                }
            }
        label: {
            Image(systemName: "location.circle")
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background(Color(UIColor.tertiarySystemBackground))
                .foregroundColor(.secondary)
                .clipShape(
                    .rect(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 8
                    )
                )
        }
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .buttonStyle(.plain)
            
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Location Services Not Enabled"),
            message: Text("To view your device's current position, location services need to be turned on"),
                  primaryButton: .default(Text("Turn On In Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }),
                  secondaryButton: .default(Text("Keep Location Services Off"))
            )
        })
    }
}

#Preview {
    LocationButtonView(locationEnabled: false, failedToStart: false, showAlert: false, locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
}
