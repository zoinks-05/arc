//
//  APIService.swift
//  Arc
//
//  Created by Ziyan Nadeem on 23/8/2026.
//
import Foundation

private let tmdbBaseURL = "https://api.themoviedb.org/3"
private let tmdbAccessToken = APIkeys.tmdbAccessToken

final class APIService {
    
    static let shared = APIService()
    private init() {}
    
    private func fetch(_ urlString: String) async throws -> [String: Any] {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(tmdbAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("TMDB Status:", httpResponse.statusCode)
        }
        
        // THIS IS IMPORTANT
        print(
            "TMDB Response:",
            String(data: data, encoding: .utf8) ?? "No response"
        )
        
        return try JSONSerialization.jsonObject(with: data)
            as? [String: Any] ?? [:]
    }
    
    func searchContent(query: String, type: String = "movie") async throws -> [String: Any] {
        
        let q = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? query
        
        return try await fetch(
            "\(tmdbBaseURL)/search/\(type)?query=\(q)"
        )
    }
    
    func fetchContentDetails(ContentID:Int, type: String = "movie") async throws -> [String: Any] {
        return try await fetch(
            "\(tmdbBaseURL)/\(type)/\(ContentID)"
        )
    }
    
    func fetchContentCredits(ContentID:Int, type: String = "movie") async throws -> [String: Any] {
        return try await fetch(
            "\(tmdbBaseURL)/\(type)/\(ContentID)/credits"
        )
    }

    func fetchContentRecommendations(ContentID:Int, type: String = "movie") async throws -> [String: Any] {
        return try await fetch(
            "\(tmdbBaseURL)/\(type)/\(ContentID)/recommendations"
        )
    }
    
    func imageURL(path: String?, width: String = "w500") -> URL?{
        guard let path, !path.isEmpty else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/\(width)\(path)")
    }
    
    func fetchGenreList(type: String) async throws -> [String: Any] {
        return try await fetch("\(tmdbBaseURL)/genre/\(type)/list")
    }
    
    func fetchGenreIDMap(type: String) async throws -> [String : Int] {
        let res = try await fetchGenreList(type: type)
        let genreObjs = res["genres"] as? [[String: Any]] ?? []
        var map: [String: Int] = [:]
        for g in genreObjs {
            if let id = g["id"] as? Int, let name = g["name"] as? String {
                map[name] = id
            }
        }
        return map
    }
    
    func fetchRecommendedContent(preferredGenres: [String]) async throws -> [String: Any] {
        guard !preferredGenres.isEmpty else {
            return try await fetchRandomHomeContent()
        }

        let type = ["movie", "tv"].randomElement()!
        let genreMap = try await fetchGenreIDMap(type: type)
        let matchingIDs = preferredGenres.compactMap { genreMap[$0] }

        guard !matchingIDs.isEmpty else {
            return try await fetchRandomHomeContent()
        }

        let genreQuery = matchingIDs.map(String.init).joined(separator: "|")
        let page = Int.random(in: 1...5)

        let endpoint = "\(tmdbBaseURL)/discover/\(type)?with_genres=\(genreQuery)&sort_by=popularity.desc&page=\(page)"
        let listResult = try await fetch(endpoint)

        guard let results = listResult["results"] as? [[String: Any]],
              var chosen = results.randomElement() else {
            throw URLError(.badServerResponse)
        }

        chosen["media_type"] = type
        return chosen
    }
    
    func fetchRandomHomeContent() async throws -> [String: Any] {
        let type = ["movie", "tv"].randomElement()!
        let category = ["popular", "top_rated", "trending"].randomElement()!
        let page = Int.random(in: 1...5)

        let endpoint: String = category == "trending"
            ? "\(tmdbBaseURL)/trending/\(type)/day?page=\(page)"
            : "\(tmdbBaseURL)/\(type)/\(category)?page=\(page)"

        let listResult = try await fetch(endpoint)

        guard let results = listResult["results"] as? [[String: Any]],
              var randomResult = results.randomElement() else {
            throw URLError(.badServerResponse)
        }
        randomResult["media_type"] = type

        return randomResult
    }
}
