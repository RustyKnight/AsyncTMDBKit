//
//  TvSeriesSummary.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol TvSeriesSummary: TvSeriesCore {
    var genreIds: [Int]? { get }
}

struct DefaultTvSeriesSummary: TvSeriesSummary, Decodable {
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case popularity = "popularity"
        case id = "id"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case overview = "overview"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case voteCount = "vote_count"
        case name = "name"
        case originalName = "original_name"
    }
    
    var id: Int
    var name: String
    var posterPath: String?
    var popularity: Double
    var backdropPath: String?
    var voteAverage: Double
    var overview: String
    var firstAirDate: String?
    var originCountry: [String]?
    var genreIds: [Int]?
    var originalLanguage: String
    var voteCount: Int
    var originalName: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decode(Double.self, forKey: .popularity)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        overview = try container.decode(String.self, forKey: .overview)
        firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
        originCountry = try container.decodeIfPresent([String].self, forKey: .originCountry)
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        originalName = try container.decode(String.self, forKey: .originalName)
    }
}
