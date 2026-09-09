//
//  UserError.swift
//  Arc
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Foundation

enum UserError: LocalizedError {

    case userNotFound
    case localUserNotFound
    case invalidUsername
    case userAlreadyExists

    var errorDescription: String? {

        switch self {

        case .userNotFound:
            return "This user could not be found."

        case .localUserNotFound:
            return "Your local user account could not be found."

        case .invalidUsername:
            return "Please enter a valid username."

        case .userAlreadyExists:
            return "This username is already in use."
        }
    }
}
