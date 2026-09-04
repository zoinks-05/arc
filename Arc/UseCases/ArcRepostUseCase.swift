//
//  RepostUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class ArcRepostUseCase {
    func execute(
        arcID: UUID,
        dataStore: DummyDataStore
    ) {
        guard let i = dataStore.arcs.firstIndex(where: { $0.id == arcID}) else { return }
        
        dataStore.arcs[i].hasReposted.toggle()
        
        if dataStore.arcs[i].hasReposted {
            dataStore.arcs[i].reposts += 1
        } else {
            dataStore.arcs[i].reposts -= 1
        }
        
        dataStore.saveData()
    }
}
