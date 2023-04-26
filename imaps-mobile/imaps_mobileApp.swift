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
    init() {
        license()
    }
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension imaps_mobileApp {
    func license() {
        if let licenseStringLiteral = String.licenseKey,
           let licenseKey = LicenseKey(licenseStringLiteral) {
               var r = try? ArcGISEnvironment.setLicense(with: licenseKey)
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
