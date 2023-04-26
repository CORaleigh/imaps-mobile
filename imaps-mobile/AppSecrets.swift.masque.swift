// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS

extension String {
    /// Your organization's ArcGIS Maps SDK [license](https://developers.arcgis.com/swift/license-and-deployment/) key.
    /// - Note: this step is optional during development but required for deployment.
    /// Licensing the app will remove the "Licensed for Developer Use Only"
    /// watermark on the map view.
    static let licenseKey: String? = {
        let licenseKey = "runtimelite,1000,rud1508631011,none,XXMFA0PL4S0BNERL1153"
        guard !licenseKey.isEmpty else {
            return nil
        }
        return licenseKey
    }()
    
    /// The extension license key for sample viewer. Required for utility network samples.
    static let extensionLicenseKey: String? = {
        let licenseKey = ""
        guard !licenseKey.isEmpty else {
            return nil
        }
        return licenseKey
    }()
}

extension APIKey {
    /// The API key for iOS sample viewer.
    static let iOS = APIKey("AAPK5a3922f5cd3d458a9fc5281430dc0c21qf2ndlLZpV5klkmHjZXDoFsziUl3txws6ahr2JHVHzHUpSdO2uBEgzzava-mGOiM")
}
