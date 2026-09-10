//
//  ReplyLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

struct ReplyLikesUseCase {

    func execute(
        replyID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let i = dataStore.replies.firstIndex(where: {
            $0.id == replyID
        }) else {
            throw ReplyError.replyNotFound
        }

        dataStore.replies[i].hasLiked.toggle()

        if dataStore.replies[i].hasLiked {
            dataStore.replies[i].likes += 1
        } else {
            dataStore.replies[i].likes = max(0, dataStore.replies[i].likes - 1)
        }

        dataStore.saveData()
    }
}
