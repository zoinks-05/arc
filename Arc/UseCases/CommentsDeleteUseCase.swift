//
//  CommentsDeleteUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

struct CommentDeleteUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore
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

        if dataStore.comments[i].text == "This comment has been removed by the user" {
            throw CommentError.commentAlreadyDeleted
        }

        dataStore.comments[i].text = "This comment has been removed by the user"
        dataStore.saveData()
    }
}
