//
//  APIRequestBuilder.swift
//  
//
//  Created by Shane Whitehead on 22/6/2022.
//

import Foundation
import AsyncAlamofireHttpEngineKit

class APIRequestBuilder: TMDBRequestBuilder {
    
    private static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    
    enum EndPoint {
        case findByExternal(id: String)
        case searchMovie
        case searchTvSeries
        case movie(id: Int)
        case tvSeries(id: Int)
        case tvSeriesSeason(id: Int, season: Int)
        case configuration
        
        var url: URL {
            switch self {
            case let .findByExternal(id):
                return baseURL
                    .appendingPathComponent("find")
                    .appendingPathComponent(id)
            case .searchMovie:
                return baseURL
                    .appendingPathComponent("search")
                    .appendingPathComponent("movie")
            case .searchTvSeries:
                return baseURL
                    .appendingPathComponent("search")
                    .appendingPathComponent("tv")
            case let .movie(id):
                return baseURL
                    .appendingPathComponent("movie")
                    .appendingPathComponent("\(id)")
            case let .tvSeries(id):
                return baseURL
                    .appendingPathComponent("tv")
                    .appendingPathComponent("\(id)")
            case let .tvSeriesSeason(id, season):
                return baseURL
                    .appendingPathComponent("tv")
                    .appendingPathComponent("\(id)")
                    .appendingPathComponent("season")
                    .appendingPathComponent("\(season)")
            case .configuration:
                return baseURL
                    .appendingPathComponent("configuration")
            }
        }
    }
    
    enum Query {
        case apiKey(String)
        case year(Int?)
        case primaryReleaseYear(Int?)
        case page(Int)
        case firstAirDateYear(Int?)
        case query(String)
        
        var name: String {
            switch self {
            case .apiKey: return "api_key"
            case .year: return "year"
            case .primaryReleaseYear: return "primary_release_year"
            case .page: return "page"
            case .firstAirDateYear: return "first_air_date_year"
            case .query: return "query"
            }
        }
    }
    
    init(_ endPoint: EndPoint, apiKey: String) {
        super.init(to: endPoint.url)
        with(.apiKey(apiKey))
    }
    
    @discardableResult
    func with(_ query: Query) -> Self {
        switch query {
        case .apiKey(let apiKey): return with(queryNamed: query.name, value: apiKey)
        case .year(let year): return withOptional(queryNamed: query.name, value: year)
        case .primaryReleaseYear(let year): return withOptional(queryNamed: query.name, value: year)
        case .page(let page): return with(queryNamed: query.name, value: page)
        case .firstAirDateYear(let year): return withOptional(queryNamed: query.name, value: year)
        case .query(let value): return with(queryNamed: query.name, value: value)
        }
    }
}
