//
//  CreateArcUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 5/9/2026.
//

import Foundation

final class CreateArcUseCase {

    func execute(
        reflection: String,
        description: String?,
        sentiment: String,
        themes: [String],
        rating: Int,
        isSpoiler: Bool,
        contentID: Int,
        contentType: String,
        dataStore: DummyDataStore,
        createdAt: Date = Date()
    ) {
        let trimmedReflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedReflection.isEmpty else {
            return
        }

        guard let user = dataStore.users.first(
            where: { $0.username == "localUser" }
        ) else {
            return
        }

        let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = (trimmedDescription?.isEmpty ?? true) ? nil : trimmedDescription

        let clampedRating = min(max(rating, 0), 10)
        let limitedThemes = Array(themes.prefix(3))

        let newArc = ArcModel(
            id: UUID(),
            userID: user.id,
            contentID: contentID,
            contentType: contentType,
            reflection: trimmedReflection,
            sentiment: sentiment,
            desription: finalDescription,
            themes: limitedThemes,
            rating: clampedRating,
            likes: 0,
            reposts: 0,
            createdAt: createdAt,
            isSpoiler: isSpoiler,
            hasLiked: false,
            hasReposted: false,
            hasSeen: true
        )

        dataStore.arcs.append(newArc)

        dataStore.saveData()
    }
}
