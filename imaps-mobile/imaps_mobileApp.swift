//
//  imaps_mobileApp.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS
@main
struct imaps_mobileApp: App {
    @StateObject var networkMonitor = NetworkMonitor()

    init() {
        license()
    }
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)

        }
    }
}

extension imaps_mobileApp {
    func license() {
        if let licenseStringLiteral = String.licenseKey,
           let licenseKey = LicenseKey(licenseStringLiteral) {
               _ = try? ArcGISEnvironment.setLicense(with: licenseKey)
           //let extensionLicenseStringLiteral = String.extensionLicenseKey,
          // let extensionLicenseKey = LicenseKey(extensionLicenseStringLiteral) {
            // Set both keys to access all samples, including utility network
            // capability.
            //try? ArcGISEnvironment.setLicense(with: licenseKey, extensions: [extensionLicenseKey])
        }
        // Authentication with an API key or named user is required to access
        // basemaps and other location services.
        ArcGISEnvironment.apiKey = .iOS
    }
}

//extension UINavigationController {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//
//    let standard = UINavigationBarAppearance()
//    standard.backgroundColor = .tertiarySystemFill //When you scroll or you have title (small one)
//
//    let compact = UINavigationBarAppearance()
//    compact.backgroundColor = .tertiarySystemFill //compact-height
//
//    let scrollEdge = UINavigationBarAppearance()
//        scrollEdge.backgroundColor = .tertiarySystemFill
//    
//        
//        
//    navigationBar.standardAppearance = standard
//    navigationBar.compactAppearance = compact
//    navigationBar.scrollEdgeAppearance = scrollEdge
//        
//    
//        
// }
//    
//}
