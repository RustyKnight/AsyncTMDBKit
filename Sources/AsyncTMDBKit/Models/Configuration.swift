//
//  Configuration.swift
//  
//
//  Created by Shane Whitehead on 22/6/2022.
//

import Foundation

public protocol ImageConfiguration {
    var baseUrl: String { get }
    var secureBaseUrl: String { get }
    var backdropSizes: [String] { get }
    var logoSizes: [String] { get }
    var posterSizes: [String] { get }
    var profileSizes: [String] { get }
    var stillSizes: [String] { get }
}

public protocol Configuration {
    var images: ImageConfiguration { get }
    var changeKeys: [String] { get }
}

struct DefaultImageConfiguration: ImageConfiguration, Decodable {
    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
        case secureBaseUrl = "secure_base_url"
        case backdropSizes = "backdrop_sizes"
        case logoSizes = "logo_sizes"
        case posterSizes = "poster_sizes"
        case profileSizes = "profile_sizes"
        case stillSizes = "still_sizes"
    }
    
    var baseUrl: String
    var secureBaseUrl: String
    var backdropSizes: [String]
    var logoSizes: [String]
    var posterSizes: [String]
    var profileSizes: [String]
    var stillSizes: [String]
}

struct DefaultConfiguration: Configuration, Decodable {
    enum CodingKeys: String, CodingKey {
        case images
        case changeKeys = "change_keys"
    }
    
    var images: ImageConfiguration
    var changeKeys: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        images = try container.decode(DefaultImageConfiguration.self, forKey: .images)
        changeKeys = try container.decode([String].self, forKey: .changeKeys)
    }
}
