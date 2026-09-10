//
//  submitReplyUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 4/9/2026.
//

import Foundation

struct SubmitReplyUseCase {

    func execute(
        content: String,
        commentID: UUID,
        dataStore: DummyDataStore,
        createdAt: Date = Date()
    ) throws {

        guard let comment = dataStore.comments.first(where: {
            $0.id == commentID
        }) else {
            throw ReplyError.parentCommentNotFound
        }

        if comment.text == "This comment has been removed by the user" {
            throw ReplyError.parentCommentDeleted
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            throw ReplyError.replyEmpty
        }

        if trimmed.count > 250 {
            throw ReplyError.replyTooLong
        }

        guard let user = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
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
