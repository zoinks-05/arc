//
//  CommentLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class CommentLikesUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore
    ) {
        guard let i = dataStore.comments.firstIndex(
            where: { $0.id == commentID }
        ) else {
            return
        }

        dataStore.comments[i].hasLiked.toggle()

        if dataStore.comments[i].hasLiked {
            dataStore.comments[i].likes += 1
        } else {
            dataStore.comments[i].likes -= 1
        }

        dataStore.saveData()
    }
}
