//
//  ReplyLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//


import Foundation

final class ReplyLikesUseCase {
    func execute(
        replyID: UUID,
        replys: inout [ReplyModel]
    ) {
        guard let i = replys.firstIndex(where: { $0.id == replyID}) else { return }
        
        replys[i].hasLiked.toggle()
        
        if replys[i].hasLiked {
            replys[i].likes += 1
        } else {
            replys[i].likes -= 1
        }
    }
}
