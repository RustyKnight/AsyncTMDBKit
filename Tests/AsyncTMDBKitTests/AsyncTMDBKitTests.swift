import XCTest
@testable import AsyncTMDBKit
import Cadmus
import AsyncAlamofireHttpEngineKit

final class AsyncTMDBKitTests: XCTestCase {
    
    override func setUp() async throws {
        TMDB.apiKey = Secrets.apiKey
        AsyncAlamofireHttpEngineConfiguration.isDebugMode = true
    }
    
    func testCanFindTv() throws {
        run {
            let response = try await TMDB.shared.findTvSeries(byTheTvDBId: "393199")
            assert(response.count == 1)
            log(debug: "\(response.first)")
        }
    }
    
    func testCanSearchMovie() throws {
        run {
            let results = try await TMDB.shared.searchMovie("A new hope")
            for result in results {
                log(debug: "\(result.id) - \(result.title)")
            }
        }
    }
    
    func testCanSearchTv() throws {
        run {
            let results = try await TMDB.shared.searchTvSeries("star")
            for result in results {
                log(debug: "\(result.id) - \(result.name)")
            }
        }
    }
    
    func testCanGetMovieDetails() throws {
        run {
            try await TMDB.shared.movie(byId: 11)
        }
    }
    
    func testCanGetTvSeriesDetails() throws {
        run {
            try await TMDB.shared.tvSeries(byId: 92830)
        }
    }
    
    func testCanGetTvSeriesSeason() throws {
        run {
            try await TMDB.shared.tvSeries(id: 92830, season: 1)
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
