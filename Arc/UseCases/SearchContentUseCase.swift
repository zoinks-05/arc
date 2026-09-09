//
//  SearchContentUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct SearchContentUseCase {

    func execute(
        query: String,
        type: String = "movie"
    ) async throws -> [[String: Any]] {

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ContentError.searchQueryEmpty
        }

        guard type == "movie" || type == "tv" else {
            throw ContentError.unsupportedContentType
        }

        do {
            let response = try await APIService.shared.searchContent(
                query: query,
                type: type
            )

            let results = response["results"] as? [[String: Any]] ?? []

            guard !results.isEmpty else {
                throw ContentError.contentNotFound
            }

            return results

        } catch let error as ContentError {
            throw error
        } catch {
            throw ContentError.contentUnavailable
        }
    }
}
