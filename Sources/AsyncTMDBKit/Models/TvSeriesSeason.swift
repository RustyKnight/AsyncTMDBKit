//
//  TvSeriesSeason.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol TvSeriesSeason {
    var overview: String { get }
    var posterPath: String? { get }
    var season: Int { get }
    var episodes: [TvSeriesEpisode] { get }
}

public protocol TvSeriesEpisode {
    var airDate: String { get }
    var episode: Int { get }
    var id: Int { get }
    var name: String { get }
    var overview: String { get }
    var season: Int { get }
    var stillPath: String? { get }
    var voteAverage: Double { get }
    var voteCount: Double { get }
}

struct DefaultTvSeriesEpisode: TvSeriesEpisode, Decodable {
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episode = "episode_number"
        case id
        case name
        case overview
        case season = "season_number"
        case stillPath = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    var airDate: String
    var episode: Int
    var id: Int
    var name: String
    var overview: String
    var season: Int
    var stillPath: String?
    var voteAverage: Double
    var voteCount: Double
}

struct DefaultTvSeriesSeason: TvSeriesSeason, Decodable {
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case overview
        case season = "season_number"
        case episodes
    }
    var overview: String
    var posterPath: String?
    var season: Int
    var episodes: [TvSeriesEpisode]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        season = try container.decode(Int.self, forKey: .season)
        episodes = try container.decode([DefaultTvSeriesEpisode].self, forKey: .episodes)
    }
}
