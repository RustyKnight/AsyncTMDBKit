//
//  File.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation

public protocol Find {
    var movies: [MovieSummary] { get }
    var tvSeries: [TvSeriesSummary] { get }
}

struct DefaultFind: Find, Decodable {
    enum CodingKeys: String, CodingKey {
        case movies = "movie_results"
        case tvSeries = "tv_results"
    }
    
    var movies: [MovieSummary]
    var tvSeries: [TvSeriesSummary]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        movies = try container.decode([DefaultMovieSummary].self, forKey: .movies)
        tvSeries = try container.decode([DefaultTvSeriesSummary].self, forKey: .tvSeries)
    }
}
