//
//  ReplyLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class ReplyLikesUseCase {

    func execute(
        replyID: UUID,
        dataStore: DummyDataStore
    ) {
        guard let i = dataStore.replies.firstIndex(
            where: { $0.id == replyID }
        ) else {
            return
        }

        dataStore.replies[i].hasLiked.toggle()

        if dataStore.replies[i].hasLiked {
            dataStore.replies[i].likes += 1
        } else {
            dataStore.replies[i].likes -= 1
        }

        dataStore.saveData()
    }
}
