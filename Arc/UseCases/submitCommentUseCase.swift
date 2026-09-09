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
    ) throws {

        guard dataStore.arcs.contains(where: { $0.id == arcID }) else {
            throw CommentError.arcNotFound
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            throw CommentError.commentEmpty
        }

        if trimmed.count > 250 {
            throw CommentError.commentTooLong
        }

        guard let user = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
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
