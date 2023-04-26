//
//  GeneralView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS

struct DeedView: View {
   // let feature: Feature?
    let attributes: [String : Any]
    let deed: [String: Any]?
        
    var body: some View {
        Group {
            Text("Deed")
                .font(.title)
            Grid {
                GridRow {
                    Text("Book")
                    Text(attributes["DEED_BOOK"] as? String ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)

                GridRow {
                    Text("Page")
                    Text(attributes["DEED_PAGE"] as? String ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)

                GridRow {
                    if (attributes["DEED_DATE"] != nil) {
                        if (type(of: attributes["DEED_DATE"]) == String.self) {
                            Text(attributes["DEED_DATE"] as! String)
                        } else if (type(of: attributes["DEED_DATE"]) == Date.self) {
                            Text(formatDate(date:attributes["DEED_DATE"] as! Date))
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)

                GridRow {
                    Text("Acres")
                    Text("\(attributes["DEED_ACRES"] as? Double ?? 0, specifier: "%.2f")")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)

                GridRow {
                    Text("Property Description")
                    Text(attributes["PROPDESC"] as? String ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)

                if (deed != nil) {
                    GridRow {
                    //                        Link(
                    //                            {
                    //                            Image(systemName: "doc")
                    //                            Text("Deed")
                    //                        }, destination: URL(string: "https://rodcrpi.wakegov.com/booksweb/pdfview.aspx?docid=\(deed?.attributes["DEED_DOC_NUM"] ?? "")&RecordDate=")!)
                    //                        .buttonStyle(.borderedProminent)
                                            if (deed?["DEED_DOC_NUM"] != nil) {
                                                NavigationLink(destination: {
                                                    WebView(request: URLRequest(url: URL(string: "https://rodcrpi.wakegov.com/booksweb/pdfview.aspx?docid=\(deed?["DEED_DOC_NUM"] ?? "")&RecordDate=")!))
                                                        .navigationTitle("Deed")
                                                },
                                                label: {
                                                    Image(systemName: "doc")
                                                    Text("Deed")
                                                })
                                                .buttonStyle(.borderedProminent)
                                                
                                               
                                            }

                                            if (deed?["BOM_DOC_NUM"] != nil) {
                                                NavigationLink(destination: {
                                                    WebView(request: URLRequest(url: URL(string: "https://rodcrpi.wakegov.com/booksweb/pdfview.aspx?docid=\(deed?["BOM_DOC_NUM"] ?? "")&RecordDate=")!))
                                                        .navigationTitle("Plat")

                                                },
                                                label: {
                                                    Image(systemName: "doc")
                                                    Text("Plat")
                                                })
                                                .buttonStyle(.borderedProminent)
                                            }

                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.all, 1)

                }
            }
        }
        .padding()

    }
}

struct DeedView_Previews: PreviewProvider {

    static var previews: some View {
        DeedView(attributes: ["DEED_BOOK": "012649", "HEATEDAREA": 1886.0, "LAND_VAL": 90000.0, "STNAME": "PIPER STREAM", "ADDR1": "644 PIPER STREAM CIR", "PROPDESC": "LO323 SEAL HARBOR & EAST HAMPTON @ TWIN LAKES BM2006 -01516", "TYPE_AND_USE": "01", "MAP_NAME": "0745 11", "PARCEL_PK": 350000, "LAND_CLASS_DECODE": "Residential Less Than 10 Acres", "OBJECTID": 61282, "DESIGN_STYLE_DECODE": "Conventional", "YEAR_BUILT": 2007, "DEED_DATE": "2007-07-12, 04:00:00 +0000", "SITE_ADDRESS": "644 PIPER STREAM CIR", "PARCEL_STATUS": "ACT", "ACTIVITY": 1100, "LAND_CLASS": "RHS", "ZIPNUM": "27519", "TOTAL_VALUE_ASSD": 352740.0, "FULL_STREET_NAME": "PIPER STREAM CIR", "OLD_PARCEL_NUMBER": "--", "TOTSALPRICE": 321000.0, "CITY": "CAR", "OBLDG_VALUE_ASSD": 0, "STRUCTURE": 1110, "TOTSTRUCTS": 1, "ADDR2": "CARY NC 27519-6405", "TOWNSHIP": "05", "DESIGNSTYL": "CVL", "PIN_EXT": "000", "STYPE": "CIR", "TOTUNITS": 1, "FUNCTION": 1100, "REID": "0350475", "PIN_NUM": "0745672212", "OWNERSHIP": 1010, "SALE_DATE": "2007-05-14 04:00:00 +0000", "BILLING_CLASS_DECODE": "Individual", "STNUM": 644, "TYPE_USE_DECODE": "SINGLFAM", "BILLCLASS": 2.0, "PLANNING_JURISDICTION": "CA", "SITE": 6100, "TOWNSHIP_DECODE": "Cedar Fork", "BLDG_VAL": 262740.0, "LAND_CODE": "R", "DEED_PAGE": "02557", "DEED_ACRES": 0.15, "CITY_DECODE": "CARY", "OWNER": "GRECO, LORA A GRECO, JUSTIN R", "UNITS": 1.0],
                 deed:["DEED_BOOK": "012649", "REID": "0350475", "BOM_DOC_NUM": 107364008, "PIN_EXT": "000", "DEED_DATE": "2007-07-12 04:00:00 +0000", "DEED_DOC_NUM": 107748071, "DEED_PAGE": "02557", "OBJECTID": 102503, "PIN_NUM": "0745672212"])
    }
}
