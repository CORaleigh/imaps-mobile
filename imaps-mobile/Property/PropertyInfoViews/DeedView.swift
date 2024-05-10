//
//  GeneralView.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 4/12/23.
//

import SwiftUI
import ArcGIS

struct DeedView: View {
    @ObservedObject var panelVM: PanelViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var isDeedActive = false
    @State private var isPlatActive = false
    
    let attributes: [String : Any]
    let deed: [String: Any]?
    
    var body: some View {
        Group {
            Text("Deed")
                .font(.title2)
            Grid {
                GridRow {
                    Text("Book")
                    Text(attributes["DEED_BOOK"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Page")
                    Text(attributes["DEED_PAGE"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    if let deedDate = attributes["DEED_DATE"] {
                        Text(deedDate is String ? deedDate as! String : formatDate(date: deedDate as! Date))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Acres")
                    Text("\(attributes["DEED_ACRES"] as? Double ?? 0, specifier: "%.2f")")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Property Description")
                    Text(attributes["PROPDESC"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                if (deed != nil) {
                    GridRow {
                        if (deed?["DEED_DOC_NUM"] != nil) {
                            
                            
                            Button{
                                self.isDeedActive = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc")
                                    Text("Deed")
                                }
                                
                                .frame(maxWidth: .infinity)
                            }
                            .navigationDestination(isPresented: $isDeedActive) {
                                if let docId = deed?["DEED_DOC_NUM"] {
                                    let urlString = "https://rodcrpi.wakegov.com/booksweb/pdfview.aspx?docid=\(docId)&RecordDate="
                                    if let url = URL(string: urlString) {
                                        WebView(request: URLRequest(url: url))
                                            .navigationTitle("Deed")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                        }
                        if (deed?["BOM_DOC_NUM"] != nil) {
                            
                            Button {
                                self.isPlatActive = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc")
                                    Text("Plat")
                                    
                                } .frame(maxWidth: .infinity)
                                
                            }
                            .navigationDestination(isPresented: $isPlatActive) {
                                if let docId = deed?["BOM_DOC_NUM"] {
                                    let urlString = "https://rodcrpi.wakegov.com/booksweb/pdfview.aspx?docid=\(docId)&RecordDate="
                                    if let url = URL(string: urlString) {
                                        WebView(request: URLRequest(url: url))
                                            .navigationTitle("Plat")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.all, 1)
                }
            }
        }
        .padding()
        .onReceive(panelVM.$selectedPinNum) { selectedPinNum in
            self.isDeedActive = false
            self.isPlatActive = false
            
        }
    }
}
//
//struct DeedView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        DeedView(attributes: ["DEED_BOOK": "012649", "HEATEDAREA": 1886.0, "LAND_VAL": 90000.0, "STNAME": "PIPER STREAM", "ADDR1": "644 PIPER STREAM CIR", "PROPDESC": "LO323 SEAL HARBOR & EAST HAMPTON @ TWIN LAKES BM2006 -01516", "TYPE_AND_USE": "01", "MAP_NAME": "0745 11", "PARCEL_PK": 350000, "LAND_CLASS_DECODE": "Residential Less Than 10 Acres", "OBJECTID": 61282, "DESIGN_STYLE_DECODE": "Conventional", "YEAR_BUILT": 2007, "DEED_DATE": "2007-07-12, 04:00:00 +0000", "SITE_ADDRESS": "644 PIPER STREAM CIR", "PARCEL_STATUS": "ACT", "ACTIVITY": 1100, "LAND_CLASS": "RHS", "ZIPNUM": "27519", "TOTAL_VALUE_ASSD": 352740.0, "FULL_STREET_NAME": "PIPER STREAM CIR", "OLD_PARCEL_NUMBER": "--", "TOTSALPRICE": 321000.0, "CITY": "CAR", "OBLDG_VALUE_ASSD": 0, "STRUCTURE": 1110, "TOTSTRUCTS": 1, "ADDR2": "CARY NC 27519-6405", "TOWNSHIP": "05", "DESIGNSTYL": "CVL", "PIN_EXT": "000", "STYPE": "CIR", "TOTUNITS": 1, "FUNCTION": 1100, "REID": "0350475", "PIN_NUM": "0745672212", "OWNERSHIP": 1010, "SALE_DATE": "2007-05-14 04:00:00 +0000", "BILLING_CLASS_DECODE": "Individual", "STNUM": 644, "TYPE_USE_DECODE": "SINGLFAM", "BILLCLASS": 2.0, "PLANNING_JURISDICTION": "CA", "SITE": 6100, "TOWNSHIP_DECODE": "Cedar Fork", "BLDG_VAL": 262740.0, "LAND_CODE": "R", "DEED_PAGE": "02557", "DEED_ACRES": 0.15, "CITY_DECODE": "CARY", "OWNER": "GRECO, LORA A GRECO, JUSTIN R", "UNITS": 1.0],
//                 deed:["DEED_BOOK": "012649", "REID": "0350475", "BOM_DOC_NUM": 107364008, "PIN_EXT": "000", "DEED_DATE": "2007-07-12 04:00:00 +0000", "DEED_DOC_NUM": 107748071, "DEED_PAGE": "02557", "OBJECTID": 102503, "PIN_NUM": "0745672212"])
//    }
//}
