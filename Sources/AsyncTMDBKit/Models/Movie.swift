//
//  Movie.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public enum MovieStatus {
    case rumoured
    case planned
    case inProduction
    case postProduction
    case released
    case canceled
    case unknown(String)
}

fileprivate extension MovieStatus {
    static func from(_ text: String) -> MovieStatus {
        switch text {
        case "Rumored": return .rumoured
        case "Planned": return .planned
        case "In Production": return .inProduction
        case "Post Production": return .postProduction
        case "Released": return .released
        case "Canceled": return .canceled
        default: return .unknown(text)
        }
    }
}

public protocol MovieExternalIds {
    var imdbId: String? { get }
    var facebookId: String? { get }
    var instagramId: String? { get }
    var twitterId: String? { get }
}

public protocol CoreMovie {
    var posterPath: String? { get }
    var adultContent: Bool? { get }
    var overview: String? { get }
    var releaseDate: String? { get }
    var id: Int { get }
    var originalTitle: String? { get }
    var originalLanguage: String? { get }
    var title: String { get }
    var backdropPath: String? { get }
    var popularity: Double { get }
    var voteCount: Int { get }
    var video: Bool { get }
    var voteAverage: Double { get }
}

public protocol Movie: CoreMovie {
    var budget: Int? { get }
    var homePage: String? { get }
    var imdbId: String? { get }
    var revenue: Int { get }
    var runtime: Int? { get }
    var status: MovieStatus { get }
    var tagline: String? { get }
    var genres: [Genre] { get }

    var images: ImageMediaGroup { get }
    var externalIds: MovieExternalIds { get }
}

struct DefaultMovieExternalIds: MovieExternalIds, Decodable {
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case facebookId = "facebook_id"
        case instagramId = "instagram_id"
        case twitterId = "twitter_id"
    }
    var imdbId: String?
    var facebookId: String?
    var instagramId: String?
    var twitterId: String?
}


struct DefaultMovie: Movie, Decodable {
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case adultContent = "adult"
        case overview
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case id
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case title = "title"
        case backdropPath = "backdrop_path"
        case popularity = "popularity"
        case voteCount = "vote_count"
        case video = "video"
        case voteAverage = "vote_average"
        case budget
        case homePage = "homepage"
        case imdbId = "imdb_id"
        case runtime = "runtime"
        case status
        case tagline
        case revenue
        case images
        case externalIds = "external_ids"
        case genres
    }
    
    var id: Int
    var title: String
    var posterPath: String?
    var adultContent: Bool?
    var overview: String?
    var releaseDate: String?
    var genreIds: [Int]?
    var originalTitle: String?
    var originalLanguage: String?
    var backdropPath: String?
    var popularity: Double
    var voteCount: Int
    var video: Bool
    var voteAverage: Double
    
    var budget: Int?
    var homePage: String?
    var imdbId: String?
    var revenue: Int
    var runtime: Int?
    var status: MovieStatus
    var tagline: String?
    
    var images: ImageMediaGroup
    var externalIds: MovieExternalIds
    var genres: [Genre]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        adultContent = try container.decodeIfPresent(Bool.self, forKey: .adultContent)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds)
        originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle)
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        popularity = try container.decode(Double.self, forKey: .popularity)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        video = try container.decode(Bool.self, forKey: .video)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)

        budget = try container.decodeIfPresent(Int.self, forKey: .budget)
        homePage = try container.decodeIfPresent(String.self, forKey: .homePage)
        imdbId = try container.decodeIfPresent(String.self, forKey: .imdbId)
        revenue = try container.decode(Int.self, forKey: .revenue)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        let statusValue = try container.decode(String.self, forKey: .status)
        status = MovieStatus.from(statusValue)
        tagline = try container.decodeIfPresent(String.self, forKey: .tagline)

        images = try container.decode(DefaultImageMediaGroup.self, forKey: .images)
        externalIds = try container.decode(DefaultMovieExternalIds.self, forKey: .externalIds)

        genres = try container.decode([DefaultGenre].self, forKey: .genres)
    }
}
