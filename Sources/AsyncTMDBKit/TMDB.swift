//
//  File.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation
import Alamofire
import AsyncAlamofireHttpEngineKit
import AsyncHttpEngineKit
import Cadmus

class TMDBRequestBuilder: AlamofireHttpRequestBuilder {
    
    private static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    
    enum EndPoint {
        case findByExternal(id: String)
        case searchMovie
        case searchTvSeries
        case movie(id: Int)
        case tvSeries(id: Int)
        case tvSeriesSeason(id: Int, season: Int)
        
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
    
    enum AppendToResponse: String {
        case images
        case externalIds = "external_ids"
    }
    
    private var appendToResponse = [AppendToResponse]()
    
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
    
    private func with(queryNamed: String, value: Int) -> Self {
        return with(queryNamed: queryNamed, value: "\(value)")
    }

    private func withOptional(queryNamed: String, value: String?) -> Self {
        if let value = value {
             with(queryNamed: queryNamed, value: value)
        }
        return self
    }

    private func withOptional(queryNamed: String, value: Int?) -> Self {
        if let value = value {
             with(queryNamed: queryNamed, value: "\(value)")
        }
        return self
    }
    
    func appendingResponse(_ appendToResponse: AppendToResponse) -> Self {
        self.appendToResponse.append(appendToResponse)
        return self
    }
    
    override func build() throws -> AsyncHttpEngine {
        if !appendToResponse.isEmpty {
            let responses = appendToResponse
                .map { $0.rawValue }
                .joined(separator: ",")
            with(queryNamed: "append_to_response", value: responses)
        }
        return try super.build()
    }

}

public class TMDB {
    public static let shared = TMDB()
    
    public enum Error: Swift.Error {
        case missingAuthorisationToken
    }
    
    public static var apiKey: String?
    
    public enum ExternalSource: String {
        case imdb = "imdb_id"
        case tvdb = "tvdb_id"
        
        private static let name = "external_source"
        
        internal var queryItem: URLQueryItem {
            return URLQueryItem(name: ExternalSource.name, value: self.rawValue)
        }
    }
    
    private init() {
    }
    
    func requestBuilderFor(_ endPoint: TMDBRequestBuilder.EndPoint) throws -> TMDBRequestBuilder {
        guard let apiKey = TMDB.apiKey else { throw Error.missingAuthorisationToken }
        return TMDBRequestBuilder(endPoint, apiKey: apiKey)
    }
    
    public func findTvSeries(byTheTvDBId id: String) async throws -> [TvSeriesSummary] {
        return try await find(byId: id, source: .tvdb).tvSeries
    }
    
    public func findMovie(byIMDBId id: String) async throws -> [MovieSummary] {
        return try await find(byId: id, source: .imdb).movies
    }

    public func find(byId id: String, source: ExternalSource) async throws -> Find {
        try await requestBuilderFor(.findByExternal(id: id))
            .with(queryItem: source.queryItem)
            .build()
            .get()
            .requestSuccessWithDataOrFail()
            .decodeTo(DefaultFind.self)
    }
    
    public func searchMovie(_ query: String, year: Int? = nil, primaryReleaseYear: Int? = nil) async throws -> [MovieSummary] {
        //https://api.themoviedb.org/3/search/movie?api_key=<<api_key>>&language=en-US&page=1&include_adult=false
        let response = try await searchMovie(query, year: year, primaryReleaseYear: primaryReleaseYear, page: 1)
        // Get first page of responses
        var searchResults = response.results
        // Are there more pages
        if response.page != response.totalPages {
            // Simultaneously request all the remaining results
            return try await withThrowingTaskGroup(of: [MovieSummary].self) { group in
                for page in 2..<response.totalPages {
                    group.addTask {
                        return try await self.searchMovie(query, year: year, primaryReleaseYear: primaryReleaseYear, page: page).results
                    }
                }
                for try await response in group {
                    searchResults.append(contentsOf: response)
                }
                // Return all the combined results
                return searchResults
            }
        }
        // Return the only page of results
        return searchResults
    }
    
    private func searchMovie(_ query: String, year: Int? = nil, primaryReleaseYear: Int? = nil, page: Int) async throws -> DefaultSearchMovieResponse {
        //https://api.themoviedb.org/3/search/movie?api_key=<<api_key>>&language=en-US&page=1&include_adult=false
        let response = try await requestBuilderFor(.searchMovie)
            .with(.query(query.replacingOccurrences(of: " ", with: "+")))
            .with(.year(year))
            .with(.primaryReleaseYear(primaryReleaseYear))
            .with(.page(page))
            .build()
            .get()
            .requestSuccessWithDataOrFail()
            .decodeTo(DefaultSearchMovieResponse.self)
        return response
    }
    
    public func searchTvSeries(_ query: String, firstAirYear: Int? = nil) async throws -> [TvSeriesSummary] {
        //https://api.themoviedb.org/3/search/tv?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US&page=1&include_adult=false
        let response = try await searchTvSeries(query, firstAirYear: firstAirYear, page: 1)
        // Get first page of responses
        var searchResults = response.results
        // Are there more pages
        if response.page != response.totalPages {
            // Simultaneously request all the remaining results
            return try await withThrowingTaskGroup(of: [TvSeriesSummary].self) { group in
                for page in 2..<response.totalPages {
                    group.addTask {
                        return try await self.searchTvSeries(query, firstAirYear: firstAirYear, page: page).results
                    }
                }
                for try await response in group {
                    searchResults.append(contentsOf: response)
                }
                // Return all the combined results
                return searchResults
            }
        }
        // Return the only page of results
        return searchResults
    }
    
    private func searchTvSeries(_ query: String, firstAirYear: Int? = nil, page: Int) async throws -> DefaultSearchTvSeriesResponse {
        //https://api.themoviedb.org/3/search/movie?api_key=<<api_key>>&language=en-US&page=1&include_adult=false
        let response = try await requestBuilderFor(.searchTvSeries)
            .with(.query(query.replacingOccurrences(of: " ", with: "+")))
            .with(.firstAirDateYear(firstAirYear))
            .with(.page(page))
            .build()
            .get()
            .requestSuccessWithDataOrFail()
            .decodeTo(DefaultSearchTvSeriesResponse.self)
        return response
    }
    
    public func movie(byId id: Int) async throws -> Movie {
        //https://api.themoviedb.org/3/movie/{movie_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
        return try await requestBuilderFor(.movie(id: id))
            .appendingResponse(.images)
            .appendingResponse(.externalIds)
            .build()
            .get()
            .requestSuccessWithDataOrFail()
            .decodeTo(DefaultMovie.self)
    }
    
    public func tvSeries(byId id: Int) async throws -> TvSeries {
        //https://api.themoviedb.org/3/tv/{tv_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
        try await requestBuilderFor(.tvSeries(id: id))
            .appendingResponse(.images)
            .appendingResponse(.externalIds)
            .build()
            .get()
            .requestSuccessWithDataOrFail()
            .debug()
            .decodeTo(DefaultTvSeries.self)
    }

    public func tvSeries(_ series: TvSeriesSummary, season: Int) async throws -> TvSeriesSeason {
        try await tvSeries(id: series.id,
                 season: season)
    }

    public func tvSeries(_ series: TvSeries, season: Int) async throws -> TvSeriesSeason {
        try await tvSeries(id: series.id,
                 season: season)
    }

    func tvSeries(id: Int, season: Int) async throws -> TvSeriesSeason {
        //https://api.themoviedb.org/3/tv/{tv_id}/season/{season_number}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
        try await requestBuilderFor(.tvSeriesSeason(id: id, season: season))
//            .appendingResponse(.images)
//            .appendingResponse(.externalIds)
            .build()
            .get()
            .requestSuccessWithDataOrFail()
//            .debug()
            .decodeTo(DefaultTvSeriesSeason.self)
    }
}

extension Data {
//    public func decode(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Int

    public func decodeTo<Value>(_ type: Value.Type) throws -> Value where Value: Decodable {
        return try JSONDecoder().decode(type, from: self)
    }
    
    @discardableResult
    public func debug() -> Data {
        log(debug: "\(String(data: self, encoding: .utf8))")
        return self
    }
}
