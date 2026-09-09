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

        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            throw ReplyError.replyEmpty
        }

        if trimmed.count > 250 {
            throw ReplyError.replyTooLong
        }

        dataStore.replies[i].text = trimmed
        dataStore.saveData()
    }
}
