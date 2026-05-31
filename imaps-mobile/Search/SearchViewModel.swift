import Foundation
enum NetworkError: Error {
    case badURL
    case badID
    case invalidURL
    case badResponse
    case invalidData
}

class Search: ObservableObject {
    @Published var searchableText = ""
    @Published var results: [SearchFeature] = [SearchFeature]()
    @Published var fetching =  false
    func getData(searchTerm: String, field: String) async throws -> [SearchFeature] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.raleighnc.gov"
        components.path = "/arcgis/rest/services/Property/Property/FeatureServer/1/query"

        if field == "ADDRESS" {
            components.path = "/arcgis/rest/services/Property/Property/FeatureServer/4/query"
        }

        let whereClause: String
        let outFields: String

        if field == "OWNER" {
            whereClause = "OWNER LIKE '\(searchTerm)%' OR OWNER2 LIKE '\(searchTerm)%'"
            outFields = "OWNER"
        } else {
            whereClause = "\(field) LIKE '\(searchTerm)%'"
            outFields = field
        }

        components.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: whereClause),
            URLQueryItem(name: "returnDistinctValues", value: "true"),
            URLQueryItem(name: "outFields", value: outFields),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "orderByFields", value: field),
            URLQueryItem(name: "maxRecordCount", value: "10")
        ]
        
        guard let url = components.url else {
            throw NetworkError.badID
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.badID
        }
        let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse?.features ?? []
    }
}
struct SearchResponse: Decodable {
    let features: [SearchFeature]
    enum CodingKeys: String, CodingKey {
        case features
    }
}
struct Attributes: Codable {
    let siteAddress: String?
    let fullStreetName: String?
    let owner: String?
    let reid: String?
    let pin: String?
    enum CodingKeys: String, CodingKey {
        case siteAddress = "ADDRESS"
        case fullStreetName = "FULL_STREET_NAME"
        case owner = "OWNER"
        case reid = "REID"
        case pin = "PIN_NUM"
    }
}
struct SearchFeature: Decodable {
    let attributes: Attributes
    enum CodingKeys: String, CodingKey {
        case attributes
    }
}
