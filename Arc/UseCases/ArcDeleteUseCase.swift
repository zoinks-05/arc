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
    ) {

        guard dataStore.arcs.contains(
            where: { $0.id == arcID }
        ) else {
            return
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

        dataStore.arcs.removeAll {
            $0.id == arcID
        }

        dataStore.saveData()
    }
}
