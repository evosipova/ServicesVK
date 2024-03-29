//
//  ServiceModel.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import Foundation

struct Service: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let link: String
    let iconUrl: URL

    enum CodingKeys: String, CodingKey {
        case name, description, link
        case iconUrl = "icon_url"
    }
}

struct ServicesList: Codable {
    let services: [Service]
}

struct ResponseData: Codable {
    let body: ServicesList
    let status: Int
}
