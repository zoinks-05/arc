//
//  LikesUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class LikesUseCase {
    func execute(
        arcID: UUID,
        arcs: inout [ArcModel]
    ) {
        guard let i = arcs.firstIndex(where: { $0.id == arcID}) else { return }
        
        arcs[i].hasLiked.toggle()
        
        if arcs[i].hasLiked {
            arcs[i].likes += 1
        } else {
            arcs[i].likes -= 1
        }
    }
}
