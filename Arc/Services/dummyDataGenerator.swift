//
//  dummyDataGenerator.swift
//  Arc
//
//  Created by Ziyan Nadeem on 4/9/2026.
//

import Foundation

struct Dataset: Codable {
    let users: [UserModel]
    let arcs: [ArcModel]
    let comments: [CommentModel]
    let replies: [ReplyModel]
}

enum DummyDataGenerator {
    static func generateDataset() -> Dataset {
        // Users
        var users = [UserModel(id: UUID(), username: "localUser", bio: "Local User Dev Testing", preferredGenres: [], followers: 0, following: 0)]
        for i in 1...30 {
            users.append(
                UserModel(
                    id: UUID(),
                    username: "user\(i)",
                    bio: "User \(i) Dev Testing",
                    preferredGenres: [],
                    followers: 0,
                    following: 0
                )
            )
        }
        
        // Content IDs for movies and TV shows
        let movies = [157336, 238, 27205]
        let tvShows = [1396, 1399, 66732]
        
        // Arcs
        var arcs: [ArcModel] = []
        for _ in 1...20 {
            let isMovie = Bool.random()
            let contentID = isMovie ? movies.randomElement()! : tvShows.randomElement()!
            let contentType = isMovie ? "movie" : "tv"
            let arc = ArcModel(
                id: UUID(),
                userID: users.randomElement()!.id,
                contentID: contentID,
                contentType: contentType,
                reflection: "This is a generated reflection.",
                sentiment: [
                    "believes",
                    "feels",
                    "thinks"
                ].randomElement()!,
                desription: "Generated description.",
                themes: [
                    "Drama",
                    "Family"
                ],
                rating: Int.random(in: 1...10),
                likes: Int.random(in: 0...500),
                reposts: Int.random(in: 0...100),
                createdAt: Date().addingTimeInterval(
                    TimeInterval(-Int.random(in: 0...604800))
                ),
                isSpoiler: Bool.random(),
                hasLiked: false,
                hasReposted: false,
                hasSeen: Bool.random()
            )
            arcs.append(arc)
        }
        
        // Comments
        var comments: [CommentModel] = []
        for arc in arcs {
            for _ in 0..<3 {
                let comment = CommentModel(
                    id: UUID(),
                    arcID: arc.id,
                    userID: users.randomElement()!.id,
                    text: [
                        "I completely agree with this.",
                        "This is such a good take.",
                        "I never thought about it this way.",
                        "The ending really got me.",
                        "This part stayed with me too."
                    ].randomElement()!,
                    likes: Int.random(in: 0...100),
                    createdAt: Date(),
                    hasLiked: false
                )
                comments.append(comment)
            }
        }
        
        // Replies
        var replies: [ReplyModel] = []
        for comment in comments {
            for _ in 0..<2 {
                let reply = ReplyModel(
                    id: UUID(),
                    commentID: comment.id,
                    userID: users.randomElement()!.id,
                    text: [
                        "Exactly.",
                        "Same here.",
                        "I agree.",
                        "That's what I thought too.",
                        "Great point."
                    ].randomElement()!,
                    likes: Int.random(in: 0...50),
                    createdAt: Date(),
                    hasLiked: false
                )
                replies.append(reply)
            }
        }
        
        return Dataset(users: users, arcs: arcs, comments: comments, replies: replies)
    }
}
