//
//  SearchContentUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct SearchContentUseCase {
    
    enum SearchError: Error {
        case EmptyQuery
        case NoResults
        
        var errorMessage: String {
            switch self {
            case .EmptyQuery:
                return "Please enter a search query."
            case .NoResults:
                return "No results found."
            }
        }
    }
    
    func execute(query: String, type: String = "movie") async throws -> [[String: Any]] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SearchError.EmptyQuery
        }
        
        do {
            let response = try await APIService.shared.searchContent(query: query, type: type)
            let results = response["results"] as? [[String: Any]] ?? []
            if results.isEmpty {
                throw SearchError.NoResults
            }
            return results
        } catch let error as SearchError {
            throw error
        } catch {
            throw SearchError.NoResults
        }
    }
}

