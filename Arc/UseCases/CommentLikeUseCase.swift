//
//  CommentLikeUseCase.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import Foundation

final class CommentLikesUseCase {
    func execute(
        commentID: UUID,
        comments: inout [CommentModel]
    ) {
        guard let i = comments.firstIndex(where: { $0.id == commentID}) else { return }
        
        comments[i].hasLiked.toggle()
        
        if comments[i].hasLiked {
            comments[i].likes += 1
        } else {
            comments[i].likes -= 1
        }
    }
}
