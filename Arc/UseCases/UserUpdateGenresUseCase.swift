//
//  UserUpdateGenres.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class UserUpdatesGenresUseCase {

    func execute(
        userID: UUID,
        dataStore: DummyDataStore,
        updatedGenres: [String]
    ) throws {

        guard let i = dataStore.users.firstIndex(where: {
            $0.id == userID
        }) else {
            throw UserError.userNotFound
        }

        dataStore.users[i].preferredGenres = updatedGenres
        dataStore.saveData()
    }
}
