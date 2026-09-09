//
//  ArcError.swift
//  Arc
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Foundation

enum ArcError: LocalizedError {

    case arcNotFound
    case reflectionTooShort
    case reflectionTooLong
    case descriptionTooLong
    case invalidSentiment
    case tooManyGenres
    case invalidRating
    case arcNotOwnedByLocalUser

    var errorDescription: String? {

        switch self {

        case .arcNotFound:
            return "This Arc could not be found."

        case .reflectionTooShort:
            return "Your reflection needs to be at least 50 characters before publishing."

        case .reflectionTooLong:
            return "Your reflection cannot be longer than 75 characters."

        case .descriptionTooLong:
            return "Your description cannot be longer than 250 characters."

        case .invalidSentiment:
            return "Please choose whether this Arc feels, believes, or thinks."

        case .tooManyGenres:
            return "You can select up to 3 genres."

        case .invalidRating:
            return "Your rating must be between 0 and 10."

        case .arcNotOwnedByLocalUser:
            return "You can only edit or delete your own Arcs."
        }
    }
}
