//
//  SearchSource.swift
//  iMAPS-SwiftUI
//
//  Created by Greco, Justin on 12/21/22.
//

import Foundation

import ArcGIS
@MainActor class SearchSources: ObservableObject, Identifiable {
    @Published var sources: [SearchSource]
    init(sources: [SearchSource]) {
        self.sources = sources
    }
}

class SearchSource: ObservableObject, Identifiable {
    var table: ServiceFeatureTable
    var fieldName: String;
    var alias: String;

    @Published var values: [ListValue] = []

    init(table: ServiceFeatureTable, fieldName: String, alias: String, values: [ListValue]) {
        self.table = table
        self.fieldName = fieldName
        self.alias = alias;
        self.values = values
    }
}

class ListValue: ObservableObject, Identifiable, Hashable {
    static func == (lhs: ListValue, rhs: ListValue) -> Bool {
        return lhs.id == rhs.id
    }
    var id: UUID
    var objectid: Int64
    var table: ServiceFeatureTable
    var field: String
    @Published var value: String
    init(id: UUID, objectid: Int64, value: String, field: String, table: ServiceFeatureTable) {
        self.id = id
        self.objectid = objectid
        self.value = value
        self.field = field
        self.table = table
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
