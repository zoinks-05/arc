//
//  ArcDeleteUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class ArcDeleteUseCase {

    func execute(
        arcID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let arcIndex = dataStore.arcs.firstIndex(where: { $0.id == arcID }) else {
            throw ArcError.arcNotFound
        }

        let localUser = dataStore.users.first(where: {
            $0.username.lowercased() == "localuser"
        })

        guard let localUser else {
            throw UserError.localUserNotFound
        }

        guard dataStore.arcs[arcIndex].userID == localUser.id else {
            throw ArcError.arcNotOwnedByLocalUser
        }

        let commentIDs = dataStore.comments
            .filter { $0.arcID == arcID }
            .map { $0.id }

        dataStore.replies.removeAll {
            commentIDs.contains($0.commentID)
        }

        dataStore.comments.removeAll {
            $0.arcID == arcID
        }

        dataStore.arcs.remove(at: arcIndex)

        dataStore.saveData()
    }
}
