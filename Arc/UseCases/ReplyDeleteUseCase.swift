//
//  ReplyDeleteUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class ReplyDeleteUseCase {

    func execute(
        replyID: UUID,
        dataStore: DummyDataStore,
    ) {
        guard let i = dataStore.replies.firstIndex(
            where: { $0.id == replyID }
        ) else {
            return
        }

        dataStore.replies[i].text = "This reply has been deleted"

        dataStore.saveData()
    }
}
