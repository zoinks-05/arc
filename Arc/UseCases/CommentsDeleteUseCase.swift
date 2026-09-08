//
//  CommentsDeleteUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 8/9/2026.
//

import Foundation

final class CommentDeleteUseCase {

    func execute(
        commentID: UUID,
        dataStore: DummyDataStore
    ) {
        guard let i = dataStore.comments.firstIndex(
            where: { $0.id == commentID }
        ) else {
            return
        }
        
        dataStore.comments[i].text = "This comment has been removed by the user"

        dataStore.saveData()
    }
}
