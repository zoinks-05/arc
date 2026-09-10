//
//  ReplyDeleteUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

struct ReplyDeleteUseCase {

    func execute(
        replyID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let i = dataStore.replies.firstIndex(where: {
            $0.id == replyID
        }) else {
            throw ReplyError.replyNotFound
        }

        guard let localUser = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        }) else {
            throw UserError.localUserNotFound
        }

        guard dataStore.replies[i].userID == localUser.id else {
            throw ReplyError.replyNotOwnedByLocalUser
        }

        if dataStore.replies[i].text == "This reply has been deleted" {
            throw ReplyError.replyNotFound
        }

        dataStore.replies[i].text = "This reply has been deleted"
        dataStore.saveData()
    }
}
