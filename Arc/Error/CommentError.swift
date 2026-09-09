//
//  CommentError.swift
//  Arc
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Foundation

enum CommentError: LocalizedError {

    case commentNotFound
    case commentEmpty
    case commentTooLong
    case arcNotFound
    case commentNotOwnedByLocalUser
    case commentAlreadyDeleted

    var errorDescription: String? {

        switch self {

        case .commentNotFound:
            return "This comment could not be found."

        case .commentEmpty:
            return "Your comment cannot be empty."

        case .commentTooLong:
            return "Your comment is too long."

        case .arcNotFound:
            return "This Arc is no longer available for comments."

        case .commentNotOwnedByLocalUser:
            return "You can only edit or delete your own comments."

        case .commentAlreadyDeleted:
            return "This comment has already been removed."
        }
    }
}
