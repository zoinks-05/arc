//
//  CommentEditUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class CommentEditUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore,
        newComment: String
    ) {
        guard let i = dataStore.comments.firstIndex(
            where: { $0.id == commentID }
        ) else {
            return
        }

        dataStore.comments[i].text = newComment

        dataStore.saveData()
    }
}
