//
//  RepostUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class RepostUseCase {
    func execute(
        arcID: UUID,
        arcs: inout [ArcModel]
    ) {
        guard let i = arcs.firstIndex(where: { $0.id == arcID}) else { return }
        
        arcs[i].hasReposted.toggle()
        
        if arcs[i].hasReposted {
            arcs[i].reposts += 1
        } else {
            arcs[i].reposts -= 1
        }
    }
}
