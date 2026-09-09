//
//  LikesUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class ArcLikesUseCase {

    func execute(
        arcID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let i = dataStore.arcs.firstIndex(where: { $0.id == arcID }) else {
            throw ArcError.arcNotFound
        }

        dataStore.arcs[i].hasLiked.toggle()

        if dataStore.arcs[i].hasLiked {
            dataStore.arcs[i].likes += 1
        } else {
            dataStore.arcs[i].likes = max(0, dataStore.arcs[i].likes - 1)
        }

        dataStore.saveData()
    }
}
