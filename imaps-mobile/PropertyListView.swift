//
//  PropertyListView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/13/23.
//

import SwiftUI
import ArcGIS


struct PropertyListView: View {
    @State var features: [Feature]
    @State var fromSearch: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
            List {
                ForEach(0..<features.count, id:\.self) { i in
                    let feature: Feature = features[i]
                    VStack {
                        NavigationLink(destination: {InfoView(feature: feature, fromSearch: fromSearch)}, label: {
                            VStack (alignment: .leading) {
                                Text(feature.attributes["SITE_ADDRESS"] as! String)
                                Text(feature.attributes["OWNER"] as! String)
                            }
                        })
                    }
                }
            }
            .toolbar {
                if (!fromSearch) {
                    Button("Close") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
    }
}

//struct PropertyListView_Previews: PreviewProvider {
//    @State static var features: [Feature] =  []
//    @
//    static func getFeatures() -> [Feature] {
//        let feature: Feature = (SharedData().table?.makeFeature(attributes: [ "SITE_ADDRESS": "6218 POOLE RD", "OWNER": "CITY OF RALEIGH "]))!
//        return [feature]
//    }
//
//    static var previews: some View {
//        PropertyListView(features: getFeatures())
//    }
//
//}
//
//struct PropertyListView_Previews: PreviewProvider {
//  
//    static var previews: some View {
//        PropertyListView(features: [["PIN_NUM": "1732793846", "STNUM": 6218, "LAND_CLASS_DECODE": "EXEMPT", "LAND_VAL": 199629.0, "TOWNSHIP_DECODE": "St. Matthew\'s", "REID": "0206687", "DEED_BOOK": "017890", "OWNERSHIP": 0, "FULL_STREET_NAME": "POOLE RD", "OLD_PARCEL_NUMBER": " 610--", "PROPDESC": "OUT PRCL A POOLE RD INVSTMT PROP BM1992 -01393", "STRUCTURE": 9000, "DEED_ACRES": 0.76, "BILLING_CLASS_DECODE": "Exempt",  "STNAME": "POOLE", "FUNCTION": 9900, "EXEMPTDESC": "RALEIGH", "PLANNING_JURISDICTION": "RA", "TOTAL_VALUE_ASSD": 199629.0, "ADDR2": "RALEIGH NC 27602-0590", "OBJECTID": 420692, "ADDR1": "PO BOX 590", "FIREDIST": "23", "TOTUNITS": 0, "PARCEL_PK": 92715, "LAND_CLASS": "XMT", "BILLCLASS": 3.0, "OBLDG_VALUE_ASSD": 0, "MAP_NAME": "1732 02", "TOTSTRUCTS": 1, "STYPE": "RD", "TOWNSHIP": "17", "EXEMPTSTAT": "RA1", "SITE_ADDRESS": "6218 POOLE RD", "SITE": 6600, "BLDG_VAL": 0.0, "DEED_PAGE": "00995", "PARCEL_STATUS": "ACT", "LAND_CODE": "E", "PIN_EXT": "000", "OWNER": "CITY OF RALEIGH ", "ACTIVITY": 9000, "UNITS": 0.0, "ZIPNUM": "27610"],
//                                    ["PIN_EXT": "000", "STYPE": "RD", "OBLDG_VALUE_ASSD": 0, "STNAME": "POOLE", "ACTIVITY": 1100, "FUNCTION": 1100, "TOWNSHIP": "17", "BLDG_VAL": 107425.0, "STRUCTURE": 1110, "STNUM": 5325, "DEED_BOOK": "017915", "PARCEL_PK": 278984, "LAND_CLASS": "XMT", "TOTUNITS": 1, "MAP_NAME": "1733 18", "SITE": 6600, "FIREDIST": "23", "TOWNSHIP_DECODE": "St. Matthew\'s", "DESIGNSTYL": "CVL", "OBJECTID": 422280, "LAND_CODE": "E", "OLD_PARCEL_NUMBER": " 582-00000-0059", "PARCEL_STATUS": "ACT", "ADDR1": "219 FAYETTEVILLE ST STE 1020", "OWNERSHIP": 4110, "SITE_ADDRESS": "5325 POOLE RD", "TYPE_USE_DECODE": "SINGLFAM", "EXEMPTDESC": "RALEIGH", "TOTSTRUCTS": 1, "DESIGN_STYLE_DECODE": "Conventional", "ADDR2": "RALEIGH NC 27601-1309", "DEED_ACRES": 0.34, "FULL_STREET_NAME": "POOLE RD", "HEATEDAREA": 1297.0, "OWNER": "CITY OF RALEIGH ", "TYPE_AND_USE": "01", "ZIPNUM": "27610", "TOTSALPRICE": 205000.0, "PIN_NUM": "1733312887", "BILLING_CLASS_DECODE": "Exempt", "LAND_VAL": 28000.0, "UNITS": 1.0, "BILLCLASS": 3.0, "LAND_CLASS_DECODE": "EXEMPT", "TOTAL_VALUE_ASSD": 135425.0, "PROPDESC": "LO3 CITY OF RALEIGH PROP BM2020 -01832", "EXEMPTSTAT": "RA1", "REID": "0034004", "DEED_PAGE": "01564", "YEAR_BUILT": 1966, "PLANNING_JURISDICTION": "RA"]])
//    }
//}
