//
//  TMDB.swift
//  
//
//  Created by Shane Whitehead on 21/6/2022.
//

import Foundation
import Alamofire
import AsyncAlamofireHttpEngineKit
import AsyncHttpEngineKit
import Cadmus



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
	
	private var configuration: Configuration?
	
	private init() {
	}
	
	func requestBuilderFor(_ endPoint: APIRequestBuilder.EndPoint) throws -> APIRequestBuilder {
		guard let apiKey = TMDB.apiKey else { throw Error.missingAuthorisationToken }
		return APIRequestBuilder(endPoint, apiKey: apiKey)
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
		if response.totalPages > 0 && response.page != response.totalPages {
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
	
	public func movie(byId id: Int) async throws -> MovieDetail {
		//https://api.themoviedb.org/3/movie/{movie_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
		return try await requestBuilderFor(.movie(id: id))
			.appendingResponse(.images)
			.appendingResponse(.externalIds)
			.build()
			.get()
			.requestSuccessWithDataOrFail()
			.decodeTo(DefaultMovie.self)
	}
	
	public func tvSeriesDetails(_ series: TvSeriesSummary) async throws -> TvSeriesDetails {
		return try await tvSeriesDetails(byId: series.id)
	}
	
	public func tvSeriesDetails(byId id: Int) async throws -> TvSeriesDetails {
		//https://api.themoviedb.org/3/tv/{tv_id}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
		let series = try await requestBuilderFor(.tvSeries(id: id))
			.appendingResponse(.images)
			.appendingResponse(.externalIds)
			.build()
			.get()
			.requestSuccessWithDataOrFail()
			.decodeTo(DefaultTvSeries.self)
		
		return try await withThrowingTaskGroup(of: TvSeriesSeason?.self) { group in
			for season in 0...series.numberOfSeasons {
				group.addTask {
					return try await self.tvSeries(series, season: season)
				}
			}
			var episods = [TvSeriesEpisode]()
			for try await response in group {
				guard let response = response else { continue }
				episods.append(contentsOf: response.episodes)
			}
			// Return all the combined results
			return DefaultTvSeriesDetails(tvSeries: series, episodes: episods)
		}
	}
	
	func tvSeries(_ series: TvSeriesSummary, season: Int) async throws -> TvSeriesSeason? {
		try await tvSeries(id: series.id,
											 season: season)
	}
	
	func tvSeries(_ series: TvSeries, season: Int) async throws -> TvSeriesSeason? {
		try await tvSeries(id: series.id,
											 season: season)
	}
	
	func tvSeries(id: Int, season: Int) async throws -> TvSeriesSeason? {
		//https://api.themoviedb.org/3/tv/{tv_id}/season/{season_number}?api_key=b8031409dad8c17a516fc3f8468be7ba&language=en-US
		let response = try await requestBuilderFor(.tvSeriesSeason(id: id, season: season))
			.build()
			.get()
		// Special use case, we accept that the season may not exist
		if response.statusCode == 404 {
			return nil
		}
		
		return try response
			.requestSuccessWithDataOrFail()
			.decodeTo(DefaultTvSeriesSeason.self)
	}
	
	public func configuration() async throws -> Configuration {
		if let configuration = configuration {
			return configuration
		}
		// https://api.themoviedb.org/3/configuration?api_key=<<api_key>>
		let response = try await requestBuilderFor(.configuration)
			.build()
			.get()
			.requestSuccessWithDataOrFail()
			.decodeTo(DefaultConfiguration.self)
		configuration = response
		return response
	}
	
	public func image(path: String, size: String = "original") async throws -> Data {
		let configuration = try await configuration()
		return try await ImageRequestBuilder(configuration, path: path, size: size)
			.build()
			.get()
			.requestSuccessWithDataOrFail()
	}
}

extension Data {
	//    public func decode(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Int
	
	func decodeTo<Value>(_ type: Value.Type) throws -> Value where Value: Decodable {
		return try JSONDecoder().decode(type, from: self)
	}
	
	@discardableResult
	func debug() -> Data {
		log(debug: "\(String(data: self, encoding: .utf8))")
		return self
	}
}
