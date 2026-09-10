//
//  CommentLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

struct CommentLikesUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let i = dataStore.comments.firstIndex(where: {
            $0.id == commentID
        }) else {
            throw CommentError.commentNotFound
        }

        dataStore.comments[i].hasLiked.toggle()

        if dataStore.comments[i].hasLiked {
            dataStore.comments[i].likes += 1
        } else {
            dataStore.comments[i].likes = max(0, dataStore.comments[i].likes - 1)
        }

        dataStore.saveData()
    }
}
