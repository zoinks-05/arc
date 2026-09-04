//
//  submitCommentUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 3/9/2026.
//

import Foundation

final class SubmitCommentUseCase {

    func execute(
        content: String,
        arcID: UUID,
        dataStore: DummyDataStore,
        createdAt: Date = Date()
    ) {
        let trimmed = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            return
        }

        guard let user = dataStore.users.first(
            where: { $0.username == "localUser" }
        ) else {
            return
        }

        let newComment = CommentModel(
            id: UUID(),
            arcID: arcID,
            userID: user.id,
            text: trimmed,
            likes: 0,
            createdAt: createdAt,
            hasLiked: false
        )

        dataStore.comments.append(newComment)

        dataStore.saveData()
    }
}
