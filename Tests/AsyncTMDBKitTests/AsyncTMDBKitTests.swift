import XCTest
@testable import AsyncTMDBKit
import Cadmus
import AsyncAlamofireHttpEngineKit
import CoreLib

final class AsyncTMDBKitTests: XCTestCase {
	
	override func setUp() async throws {
		TMDB.apiKey = Secrets.apiKey
		AsyncAlamofireHttpEngineConfiguration.isDebugMode = true
	}
	
	func testCanFindTv() throws {
		run {
			let response = try await TMDB.shared.findTvSeries(byTheTvDBId: 393199)
			assert(response.count == 1)
			log(debug: "\(response.first)")
		}
	}
	
	func testCanSearchMovie() throws {
		run {
			let progress = NormalizedProgress()
			progress.onChange = { progress in
				log(debug: "Progress = \(progress.value)")
			}
			let results = try await TMDB.shared.searchMovie("Star Wars", progress: progress)
			for result in results {
				log(debug: "\(result.id) - \(result.title)")
			}
		}
	}
	
	func testCanSearchTv() throws {
		run {
			let progress = NormalizedProgress()
			progress.onChange = { progress in
				log(debug: "Progress = \(progress.value)")
			}
			let results = try await TMDB.shared.searchTvSeries("doctor who", progress: progress)
			log(debug: "Found \(results.count) matches")
			for result in results {
				log(debug: "\(result.id) - \(result.name)")
			}
		}
	}
	
	func testCanGetMovieDetails() throws {
		run {
			_ = try await TMDB.shared.movie(byId: 11)
		}
	}
	
	func testCanGetTvSeriesDetails() throws {
		run {
			let progress = NormalizedProgress()
			progress.onChange = { progress in
				log(debug: "Progress = \(progress.value)")
			}
			//121
			let series = try await TMDB.shared.tvSeriesDetails(byId: 57243, progress: progress)
			log(debug: "Episode count = \(series.episodes.count)")
			log(debug: "numberOfSeasons = \(series.numberOfSeasons)")
			log(debug: "Season id = \(series.seasons.first?.id)")
			log(debug: "Backdrop = \(String(describing: series.backdropPath))")
			log(debug: "Poster = \(String(describing: series.posterPath))")
		}
	}
	
	func testCanGetTvSeriesSeason() throws {
		run {
			_ = try await TMDB.shared.tvSeries(id: 92830, season: 0)
		}
	}
	
	func testCanGetConfiguration() throws {
		run {
			_ = try await TMDB.shared.configuration()
		}
	}
	
	func testCanGetImage() throws {
		run {
			let progress = NormalizedProgress()
			progress.onChange = { progress in
				log(debug: "Progress = \(progress.value)")
			}
			_ = try await TMDB.shared.image(path: "/8H64YmIYxpRJgSTuLUGRUSyi2kN.jpg", progress: progress)
		}
	}
	
	func run(_ test: @escaping () async throws -> Void) {
		let stopWatch = StopWatch().start()
		let exp = expectation(description: "Tv series details")
		Task {
			do {
				try await test()
			} catch {
				XCTFail("\(error)")
			}
			log(debug: "Fulfill...")
			exp.fulfill()
		}
		waitForExpectations(timeout: 3600.0, handler: { (error) in
			log(debug: "Completed...")
			guard let error = error else {
				return
			}
			XCTFail("\(error)")
		})
		log(debug: "Completed in \(stopWatch)")
	}
}
