//
//  ArcAPITests.swift
//  Arc
//
//  Created by Ziyan Nadeem on 10/9/2026.
//

import Testing
@testable import Arc
import Foundation

@Suite("Arc API Tests")
struct ArcAPITests {
    
    @Test("TMDB API can fetch content")
    func tmdbCanFetchContent() async throws {
        let result = try await APIService.shared.fetchContentDetails(
            ContentID: 157336,
            type: "movie"
        )
        
        #expect(result["id"] as? Int == 157336)
        #expect(result["title"] as? String == "Interstellar")
    }
    
    @Test("TMDB API can search for a movie")
    func tmdbCanSearchMovie() async throws {
        let result = try await APIService.shared.searchContent(
            query: "Bleach",
            type: "movie"
        )
        
        let results = try #require(
            result["results"] as? [[String: Any]]
        )
        
        #expect(!results.isEmpty)
    }
    
    @Test("TMDB API rejects invalid content type")
    func tmdbRejectsInvalidContentType() async throws {
        let result = try await APIService.shared.fetchContentDetails(
            ContentID: 157336,
            type: "invalid"
        )

        #expect(result["status_code"] as? Int != 200)
    }
}
