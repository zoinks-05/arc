//
//  CommentEditUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

struct CommentEditUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore,
        newComment: String
    ) throws {

        guard let i = dataStore.comments.firstIndex(where: {
            $0.id == commentID
        }) else {
            throw CommentError.commentNotFound
        }

        guard let localUser = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
        }

        guard dataStore.comments[i].userID == localUser.id else {
            throw CommentError.commentNotOwnedByLocalUser
        }

        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            throw CommentError.commentEmpty
        }

        if trimmed.count > 250 {
            throw CommentError.commentTooLong
        }

        dataStore.comments[i].text = trimmed
        dataStore.saveData()
    }
}
