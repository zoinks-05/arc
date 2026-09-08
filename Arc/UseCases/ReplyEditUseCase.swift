//
//  ReplyEditUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class ReplyEditUseCase {

    func execute(
        replyID: UUID,
        dataStore: DummyDataStore,
        newComment: String
    ) {
        guard let i = dataStore.replies.firstIndex(
            where: { $0.id == replyID }
        ) else {
            return
        }

        dataStore.replies[i].text = newComment

        dataStore.saveData()
    }
}
