//
//  File.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol SearchResponse {
    associatedtype Result
    var page: Int { get }
    var totalResults: Int { get }
    var totalPages: Int { get }
    var results: [Result] { get }
}

public protocol SearchMovieResponse: SearchResponse {
    var results: [MovieSummary] { get }
}

public protocol SearchTvSeriesResponse: SearchResponse {
    var results: [TvSeriesSummary] { get }
}

struct DefaultSearchMovieResponse: SearchMovieResponse, Decodable {
    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results = "results"
    }
    var results: [MovieSummary]
    var page: Int
    var totalResults: Int
    var totalPages: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decode(Int.self, forKey: .page)
        totalResults = try container.decode(Int.self, forKey: .totalResults)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
        results = try container.decode([DefaultMovieSummary].self, forKey: .results)
    }
}

struct DefaultSearchTvSeriesResponse: SearchTvSeriesResponse, Decodable {
    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results = "results"
    }
    var results: [TvSeriesSummary]
    var page: Int
    var totalResults: Int
    var totalPages: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decode(Int.self, forKey: .page)
        totalResults = try container.decode(Int.self, forKey: .totalResults)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
        results = try container.decode([DefaultTvSeriesSummary].self, forKey: .results)
    }
}
