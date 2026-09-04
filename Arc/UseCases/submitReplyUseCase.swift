//
//  submitReplyUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 4/9/2026.
//

import Foundation

final class SubmitReplyUseCase {

    func execute(
        content: String,
        commentID: UUID,
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

        let newReply = ReplyModel(
            id: UUID(),
            commentID: commentID,
            userID: user.id,
            text: trimmed,
            likes: 0,
            createdAt: createdAt,
            hasLiked: false
        )

        dataStore.replies.append(newReply)

        dataStore.saveData()
    }
}
