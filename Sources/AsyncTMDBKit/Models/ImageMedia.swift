//
//  ImageMedia.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol ImageMedia {
    var aspectRatio: Double { get }
    var filePath: String { get }
    var height: Int { get }
    var voteAverage: Double { get }
    var voteCount: Int { get }
    var width: Int { get }
}

public protocol ImageMediaGroup {
    var backdrops: [ImageMedia] { get }
    var logos: [ImageMedia] { get }
    var posters: [ImageMedia] { get }
}

struct DefaultImageMedia: ImageMedia, Decodable {
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case height
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case width
    }

    var aspectRatio: Double
    var filePath: String
    var height: Int
    var voteAverage: Double
    var voteCount: Int
    var width: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aspectRatio = try container.decode(Double.self, forKey: .aspectRatio)
        filePath = try container.decode(String.self, forKey: .filePath)
        height = try container.decode(Int.self, forKey: .height)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        width = try container.decode(Int.self, forKey: .width)
    }
}

struct DefaultImageMediaGroup: ImageMediaGroup, Decodable {
    enum CodingKeys: String, CodingKey {
        case backdrops
        case logos
        case posters
    }

    var backdrops: [ImageMedia]
    var logos: [ImageMedia]
    var posters: [ImageMedia]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backdrops = try container.decode([DefaultImageMedia].self, forKey: .backdrops)
        logos = try container.decode([DefaultImageMedia].self, forKey: .logos)
        posters = try container.decode([DefaultImageMedia].self, forKey: .posters)
    }
}
