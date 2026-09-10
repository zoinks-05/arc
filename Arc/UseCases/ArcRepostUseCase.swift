//
//  RepostUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

struct ArcRepostUseCase {

    func execute(
        arcID: UUID,
        dataStore: DummyDataStore
    ) throws {

        guard let i = dataStore.arcs.firstIndex(where: { $0.id == arcID }) else {
            throw ArcError.arcNotFound
        }

        dataStore.arcs[i].hasReposted.toggle()

        if dataStore.arcs[i].hasReposted {
            dataStore.arcs[i].reposts += 1
        } else {
            dataStore.arcs[i].reposts = max(0, dataStore.arcs[i].reposts - 1)
        }

        dataStore.saveData()
    }
}
