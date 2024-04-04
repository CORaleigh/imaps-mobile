import Foundation
enum NetworkError: Error {
    case badURL
    case badID
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
        components.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "\(field) LIKE '\(searchTerm)%'"),
            URLQueryItem(name: "returnDistinctValues", value: "true"),
            URLQueryItem(name: "outFields", value: field),
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
        case siteAddress = "SITE_ADDRESS"
        case fullStreetName = "FULL_STREET_NAME"
        case owner = "OWNER"
        case reid = "REID"
        case pin = "PIN"
        
    }
}
struct SearchFeature: Decodable {
    let attributes: Attributes
    enum CodingKeys: String, CodingKey {
        case attributes
    }
}
