import SwiftUI
import ArcGIS
import CoreLocation

struct LocationButtonView: View {
    @State var locationEnabled: Bool
    @State  var failedToStart: Bool
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
    }
}

#Preview {
    LocationButtonView(locationEnabled: false, failedToStart: false, locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
}
