//
//  ArcEditUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

struct ArcEditUseCase {

    func execute(
        arcID: UUID,
        dataStore: DummyDataStore,
        newReflection: String?,
        newDescription: String?,
        newSentiment: String?,
        newThemes: [String?],
        newRating: Int?,
        newIsSpoiler: Bool?
    ) throws {

        guard let i = dataStore.arcs.firstIndex(where: { $0.id == arcID }) else {
            throw ArcError.arcNotFound
        }

        guard let localUser = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
        }

        guard dataStore.arcs[i].userID == localUser.id else {
            throw ArcError.arcNotOwnedByLocalUser
        }

        if let newReflection {
            let reflection = newReflection.trimmingCharacters(in: .whitespacesAndNewlines)

            if reflection.count < 50 {
                throw ArcError.reflectionTooShort
            }

            if reflection.count > 75 {
                throw ArcError.reflectionTooLong
            }

            dataStore.arcs[i].reflection = reflection
        }

        if let newDescription {
            if newDescription.count > 250 {
                throw ArcError.descriptionTooLong
            }

            dataStore.arcs[i].desription = newDescription
        }

        if let newSentiment {
            guard ["feels", "believes", "thinks"].contains(newSentiment.lowercased()) else {
                throw ArcError.invalidSentiment
            }

            dataStore.arcs[i].sentiment = newSentiment
        }

        let themes = newThemes.compactMap { $0 }

        if themes.count > 3 {
            throw ArcError.tooManyGenres
        }

        if !themes.isEmpty {
            dataStore.arcs[i].themes = themes
        }

        if let newRating {
            guard (0...10).contains(newRating) else {
                throw ArcError.invalidRating
            }

            dataStore.arcs[i].rating = newRating
        }

        if let newIsSpoiler {
            dataStore.arcs[i].isSpoiler = newIsSpoiler
        }

        dataStore.saveData()
    }
}
