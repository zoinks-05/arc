//
//  CommentModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct CommentModel: Identifiable {
    
    let id: UUID
    let arcID: UUID
    let userID: UUID
    
    var text: String
    var likes: Int
    var createdAt: Date
    var hasLiked: Bool
}

extension CommentModel {

    static func sampleData(from arcs: [ArcModel]) -> [CommentModel] {
        let commentPool: [[String]] = [
            [
                "This movie completely changed the way I think about time.",
                "The ending still gets me every time."
            ],
            [
                "Underrated. People sleep on this one.",
                "The pacing dragged for me but the visuals carried it."
            ],
            [
                "Rewatched this last night and it hit even harder.",
                "Not gonna lie, I cried at the finale."
            ],
            [
                "The soundtrack alone deserves an award.",
                "Character development was so well done here."
            ],
            [
                "This is going straight into my favorites."
            ]
        ]

        var comments: [CommentModel] = []

        for (index, arc) in arcs.enumerated() {
            // Skip every 3rd arc so not every arc has comments
            if index % 3 == 2 { continue }

            let lines = commentPool[index % commentPool.count]
            for (i, line) in lines.enumerated() {
                comments.append(
                    CommentModel(
                        id: UUID(),
                        arcID: arc.id,
                        userID: UUID(),
                        text: line,
                        likes: Int.random(in: 2...60),
                        createdAt: Date().addingTimeInterval(-Double(900 * (i + 1) * (index + 1))),
                        hasLiked: Bool.random()
                    )
                )
            }
        }

        return comments
    }
}
