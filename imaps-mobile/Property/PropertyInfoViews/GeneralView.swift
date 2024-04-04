import SwiftUI
import ArcGIS

struct GeneralView: View {
    let attributes: [String : Any]
    var body: some View {
        Group {
            Text("General")
                .font(.title2)
            
            Grid {
                GridRow {
                    Text("PIN")
                    Text(attributes["PIN_NUM"] as? String ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("REID")
                    Text(attributes["REID"] as? String ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("City")
                    let city = attributes["CITY_DECODE"] as? String ?? ""
                    Text(city.capitalized)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Jurisdiction")
                    let value = decodeJurisdiction(value: attributes["PLANNING_JURISDICTION"] as? String ?? "")
                    Text(value)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Township")
                    Text(attributes["TOWNSHIP_DECODE"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Map Name")
                    Text(attributes["MAP_NAME"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
                
                GridRow {
                    Text("Land Class")
                    Text(attributes["LAND_CLASS_DECODE"] as? String ?? "")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 1)
            }
        }
        .padding()
    }
}

func decodeJurisdiction(value: String) -> String {
    return switch value {
    case "AN":
        "Angier"
    case "AP":
        "Apex"
    case "CA":
        "Cary"
    case "CL":
        "Clayton"
    case "DU":
        "Durham"
    case "FV":
        "Fuquay-Varina"
    case "GA":
        "Garner"
    case "HO":
        "Holly Springs"
    case "KN":
        "Knightdale"
    case "MO":
        "Morrisville"
    case "RA":
        "Raleigh"
    case "RO":
        "Rolesville"
    case "WC":
        "Wake County"
    case "WE":
        "Wendell"
    case "WF":
        "Wake Forest"
    case "ZB":
        "Zebulon"
    default:
        value
    }
    
}

struct GeneralView_Previews: PreviewProvider {
    
    static var previews: some View {
        GeneralView(attributes: ["DEED_BOOK": "012649", "HEATEDAREA": 1886.0, "LAND_VAL": 90000.0, "STNAME": "PIPER STREAM", "ADDR1": "644 PIPER STREAM CIR", "PROPDESC": "LO323 SEAL HARBOR & EAST HAMPTON @ TWIN LAKES BM2006 -01516", "TYPE_AND_USE": "01", "MAP_NAME": "0745 11", "PARCEL_PK": 350000, "LAND_CLASS_DECODE": "Residential Less Than 10 Acres", "OBJECTID": 61282, "DESIGN_STYLE_DECODE": "Conventional", "YEAR_BUILT": 2007, "DEED_DATE": "2007-07-12, 04:00:00 +0000", "SITE_ADDRESS": "644 PIPER STREAM CIR", "PARCEL_STATUS": "ACT", "ACTIVITY": 1100, "LAND_CLASS": "RHS", "ZIPNUM": "27519", "TOTAL_VALUE_ASSD": 352740.0, "FULL_STREET_NAME": "PIPER STREAM CIR", "OLD_PARCEL_NUMBER": "--", "TOTSALPRICE": 321000.0, "CITY": "CAR", "OBLDG_VALUE_ASSD": 0, "STRUCTURE": 1110, "TOTSTRUCTS": 1, "ADDR2": "CARY NC 27519-6405", "TOWNSHIP": "05", "DESIGNSTYL": "CVL", "PIN_EXT": "000", "STYPE": "CIR", "TOTUNITS": 1, "FUNCTION": 1100, "REID": "0350475", "PIN_NUM": "0745672212", "OWNERSHIP": 1010, "SALE_DATE": "2007-05-14 04:00:00 +0000", "BILLING_CLASS_DECODE": "Individual", "STNUM": 644, "TYPE_USE_DECODE": "SINGLFAM", "BILLCLASS": 2.0, "PLANNING_JURISDICTION": "CA", "SITE": 6100, "TOWNSHIP_DECODE": "Cedar Fork", "BLDG_VAL": 262740.0, "LAND_CODE": "R", "DEED_PAGE": "02557", "DEED_ACRES": 0.15, "CITY_DECODE": "CARY", "OWNER": "GRECO, LORA A GRECO, JUSTIN R", "UNITS": 1.0])
    }
}
