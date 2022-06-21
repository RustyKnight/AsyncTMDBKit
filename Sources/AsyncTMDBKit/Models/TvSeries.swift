//
//  TvSeries.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol TvSeriesCore {
    var id: Int { get }
    var name: String { get }
    var posterPath: String? { get }
    var popularity: Double { get }
    var backdropPath: String? { get }
    var voteAverage: Double { get }
    var overview: String { get }
    var firstAirDate: String? { get }
    var originCountry: [String]? { get }
    var originalLanguage: String { get }
    var voteCount: Int { get }
    var originalName: String { get }
}

public protocol TvSeriesExternalIds {
    var imdbId: String? { get }
    var tvdbId: Int? { get }
}

public protocol TvSeries: TvSeriesCore {
    var homepage: String { get }
    var inProduction: Bool { get }
    var lastAirDate: String { get }
    var numberOfEpisodes: Int { get }
    var numberOfSeasons: Int { get }
    var status: String { get }
    var tagline: String { get }
    var type: String { get }
    var genres: [Genre] { get }

    var images: ImageMediaGroup { get }
    var externalIds: TvSeriesExternalIds { get }
}

public protocol TvSeriesDetails: TvSeries {
    var episodes: [TvSeriesEpisode] { get }
}

struct DefaultTvSeriesExternalIds: TvSeriesExternalIds, Decodable {
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case tvdbId = "tvdb_id"
    }
    var imdbId: String?
    var tvdbId: Int?
}

struct DefaultTvSeries: TvSeries, Decodable {
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case popularity = "popularity"
        case id = "id"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case overview = "overview"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case voteCount = "vote_count"
        case name = "name"
        case originalName = "original_name"

        case homepage
        case inProduction = "in_production"
        case lastAirDate = "last_air_date"
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case status = "status"
        case tagline = "tagline"
        case type = "type"
        case genres
        case images
        case externalIds = "external_ids"
    }
    
    var id: Int
    var name: String
    var posterPath: String?
    var backdropPath: String?
    var firstAirDate: String?
    var originCountry: [String]?
    
    var popularity: Double
    var voteAverage: Double
    var overview: String
    var originalLanguage: String
    var voteCount: Int
    var originalName: String

    var homepage: String
    var inProduction: Bool
    var lastAirDate: String
    var numberOfEpisodes: Int
    var numberOfSeasons: Int
    var status: String
    var tagline: String
    var type: String
    var genres: [Genre]

    var images: ImageMediaGroup
    var externalIds: TvSeriesExternalIds

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decode(Double.self, forKey: .popularity)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        overview = try container.decode(String.self, forKey: .overview)
        firstAirDate = try container.decode(String.self, forKey: .firstAirDate)
        originCountry = try container.decodeIfPresent([String].self, forKey: .originCountry)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        originalName = try container.decode(String.self, forKey: .originalName)

        homepage = try container.decode(String.self, forKey: .homepage)
        inProduction = try container.decode(Bool.self, forKey: .inProduction)
        lastAirDate = try container.decode(String.self, forKey: .lastAirDate)
        numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        numberOfSeasons = try container.decode(Int.self, forKey: .numberOfSeasons)
        status = try container.decode(String.self, forKey: .status)
        tagline = try container.decode(String.self, forKey: .tagline)
        type = try container.decode(String.self, forKey: .type)
        genres = try container.decode([DefaultGenre].self, forKey: .genres)

        images = try container.decode(DefaultImageMediaGroup.self, forKey: .images)
        externalIds = try container.decode(DefaultTvSeriesExternalIds.self, forKey: .externalIds)
    }
}

struct DefaultTvSeriesDetails: TvSeriesDetails {
    var episodes: [TvSeriesEpisode]
    var homepage: String
    var inProduction: Bool
    var lastAirDate: String
    var numberOfEpisodes: Int
    var numberOfSeasons: Int
    var status: String
    var tagline: String
    var type: String
    var genres: [Genre]
    var images: ImageMediaGroup
    var externalIds: TvSeriesExternalIds
    var id: Int
    var name: String
    var posterPath: String?
    var popularity: Double
    var backdropPath: String?
    var voteAverage: Double
    var overview: String
    var firstAirDate: String?
    var originCountry: [String]?
    var originalLanguage: String
    var voteCount: Int
    var originalName: String
    
    init(tvSeries: TvSeries, episodes: [TvSeriesEpisode]) {
        self.episodes = episodes
        self.homepage = tvSeries.homepage
        self.inProduction = tvSeries.inProduction
        self.lastAirDate = tvSeries.lastAirDate
        self.numberOfEpisodes = tvSeries.numberOfEpisodes
        self.numberOfSeasons = tvSeries.numberOfSeasons
        self.status = tvSeries.status
        self.tagline = tvSeries.tagline
        self.type = tvSeries.type
        self.genres = tvSeries.genres
        self.images = tvSeries.images
        self.externalIds = tvSeries.externalIds
        self.id = tvSeries.id
        self.name = tvSeries.name
        self.posterPath = tvSeries.posterPath
        self.popularity = tvSeries.popularity
        self.backdropPath = tvSeries.backdropPath
        self.voteAverage = tvSeries.voteAverage
        self.overview = tvSeries.overview
        self.firstAirDate = tvSeries.firstAirDate
        self.originCountry = tvSeries.originCountry
        self.originalLanguage = tvSeries.originalLanguage
        self.voteCount = tvSeries.voteCount
        self.originalName = tvSeries.originalName
    }
}
