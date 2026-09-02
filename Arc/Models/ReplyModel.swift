//
//  ReplyModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct ReplyModel: Identifiable {
    
    let id: UUID
    let commentID: UUID
    let userID: UUID
    
    var text: String
    var likes: Int
    var createdAt: Date
    var hasLiked: Bool
}

extension ReplyModel {

    static func sampleData(from comments: [CommentModel]) -> [ReplyModel] {
        let replyPool: [[String]] = [
            ["Same. The ending was incredible.", "Especially that final scene."],
            ["Absolutely agree."],
            ["Honestly didn't expect that twist."],
            [] // some comments get zero replies
        ]

        var replies: [ReplyModel] = []

        for (index, comment) in comments.enumerated() {
            // Skip every other comment so not all of them have replies
            if index % 2 == 1 { continue }

            let lines = replyPool[index % replyPool.count]
            for (i, line) in lines.enumerated() {
                replies.append(
                    ReplyModel(
                        id: UUID(),
                        commentID: comment.id,
                        userID: UUID(),
                        text: line,
                        likes: Int.random(in: 1...20),
                        createdAt: Date().addingTimeInterval(-Double(300 * (i + 1) * (index + 1))),
                        hasLiked: Bool.random()
                    )
                )
            }
        }

        return replies
    }
}
