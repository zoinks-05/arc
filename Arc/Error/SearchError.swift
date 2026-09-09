//
//  SearchError.swift
//  Arc
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Foundation

enum ContentError: LocalizedError {

    case contentNotFound
    case unsupportedContentType
    case searchQueryEmpty
    case contentUnavailable

    var errorDescription: String? {

        switch self {

        case .contentNotFound:
            return "We couldn't find this movie or TV show."

        case .unsupportedContentType:
            return "This type of content is not supported."

        case .searchQueryEmpty:
            return "Enter a title to search for content."

        case .contentUnavailable:
            return "This content is currently unavailable."
        }
    }
}
