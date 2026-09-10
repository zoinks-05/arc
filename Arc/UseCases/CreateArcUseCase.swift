//
//  CreateArcUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 5/9/2026.
//

import Foundation

struct CreateArcUseCase {

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
    ) throws {

        let trimmedReflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedReflection.count < 50 {
            throw ArcError.reflectionTooShort
        }

        if trimmedReflection.count > 75 {
            throw ArcError.reflectionTooLong
        }

        if let description,
           description.trimmingCharacters(in: .whitespacesAndNewlines).count > 250 {
            throw ArcError.descriptionTooLong
        }

        guard ["feels", "believes", "thinks"].contains(sentiment.lowercased()) else {
            throw ArcError.invalidSentiment
        }

        if themes.count > 3 {
            throw ArcError.tooManyGenres
        }

        guard (0...10).contains(rating) else {
            throw ArcError.invalidRating
        }

        guard let user = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
        }

        let trimmedDescription = description?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let finalDescription = trimmedDescription?.isEmpty == true
            ? nil
            : trimmedDescription

        let newArc = ArcModel(
            id: UUID(),
            userID: user.id,
            contentID: contentID,
            contentType: contentType,
            reflection: trimmedReflection,
            sentiment: sentiment,
            desription: finalDescription,
            themes: themes,
            rating: rating,
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
