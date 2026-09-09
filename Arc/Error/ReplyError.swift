//
//  ReplyError.swift
//  Arc
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Foundation

enum ReplyError: LocalizedError {

    case replyNotFound
    case replyEmpty
    case replyTooLong
    case parentCommentNotFound
    case replyNotOwnedByLocalUser
    case parentCommentDeleted

    var errorDescription: String? {

        switch self {

        case .replyNotFound:
            return "This reply could not be found."

        case .replyEmpty:
            return "Your reply cannot be empty."

        case .replyTooLong:
            return "Your reply is too long."

        case .parentCommentNotFound:
            return "You cannot reply because the original comment could not be found."

        case .replyNotOwnedByLocalUser:
            return "You can only edit or delete your own replies."

        case .parentCommentDeleted:
            return "You cannot reply to a comment that has been removed."
        }
    }
}
