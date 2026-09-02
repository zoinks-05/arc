//
//  ArcModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct ArcModel: Identifiable {
    
    let id: UUID
    let userID: UUID
    let contentID: Int
    let contentType: String
    
    var reflection: String
    var sentiment: String // Now just "believes", "feels", etc.
    var desription: String?
    var themes: [String]
    
    var rating: Int
    var likes: Int
    var reposts: Int
    let createdAt: Date
    
    var isSpoiler: Bool
    var hasLiked: Bool
    var hasReposted: Bool
    var hasSeen: Bool
}

extension ArcModel {
    static let sampleData: [ArcModel] = [
        // Movies
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 157336, // Interstellar
            contentType: "movie",
            reflection: "This film completely reframed how I think about isolation and connection — the pacing let every silence land.",
            sentiment: "believes",
            desription: "A slow-burn character study.",
            themes: ["Isolation", "Hope", "Sacrifice"],
            rating: 9,
            likes: 214000,
            reposts: 5200,
            createdAt: Date().addingTimeInterval(-3600 * 2),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 17165,
            contentType: "movie",
            reflection: "Didn't expect the twist in the third act — genuinely recontextualizes the whole first half.",
            sentiment: "feels",
            desription: nil,
            themes: ["Betrayal", "Identity"],
            rating: 7,
            likes: 89,
            reposts: 5,
            createdAt: Date().addingTimeInterval(-3600 * 6),
            isSpoiler: true,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 238, // The Godfather
            contentType: "movie",
            reflection: "A masterclass in tension — every scene feels inevitable in hindsight.",
            sentiment: "considers",
            desription: "Rewatched it three times already.",
            themes: ["Power", "Family", "Legacy"],
            rating: 10,
            likes: 512,
            reposts: 37,
            createdAt: Date().addingTimeInterval(-3600 * 24),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        // TVs
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 1399, // Game of Thrones
            contentType: "tv",
            reflection: "The final season really let the earlier seasons down — pacing fell apart after such a strong build-up.",
            sentiment: "regrets",
            desription: "Loved the show until the last stretch.",
            themes: ["Disappointment", "Power", "Legacy"],
            rating: 4,
            likes: 328,
            reposts: 21,
            createdAt: Date().addingTimeInterval(-3600 * 30),
            isSpoiler: true,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 66732, // Stranger Things
            contentType: "tv",
            reflection: "Nostalgic without feeling lazy — the kid cast carries the emotional weight better than most adult ensembles.",
            sentiment: "relates",
            desription: nil,
            themes: ["Nostalgia", "Friendship", "Fear"],
            rating: 8,
            likes: 176,
            reposts: 12,
            createdAt: Date().addingTimeInterval(-3600 * 48),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 1396, // Breaking Bad
            contentType: "tv",
            reflection: "Every choice this character makes feels earned — no shortcuts, no forced redemption arcs.",
            sentiment: "admires",
            desription: "One of the tightest character studies ever written.",
            themes: ["Morality", "Consequence", "Transformation"],
            rating: 10,
            likes: 891,
            reposts: 64,
            createdAt: Date().addingTimeInterval(-3600 * 72),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        
        // Duplicates (same contentID/contentType, different UUID id)
        // Interstellar duplicate (exact same fields)
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 157336, // Interstellar
            contentType: "movie",
            reflection: "This film completely reframed how I think about isolation and connection — the pacing let every silence land.",
            sentiment: "believes",
            desription: "A slow-burn character study.",
            themes: ["Isolation", "Hope", "Sacrifice"],
            rating: 9,
            likes: 214000,
            reposts: 5200,
            createdAt: Date().addingTimeInterval(-3600 * 2),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        // Interstellar near-duplicate (slight variation)
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 157336,
            contentType: "movie",
            reflection: "Every rewatch hits harder — the sound design still gives me chills.",
            sentiment: "believes",
            desription: "Zimmer's score is unreal.",
            themes: ["Isolation", "Hope", "Time"],
            rating: 9,
            likes: 215200,
            reposts: 5400,
            createdAt: Date().addingTimeInterval(-3600 * 5),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        // Godfather duplicate
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 238, // The Godfather
            contentType: "movie",
            reflection: "A masterclass in tension — every scene feels inevitable in hindsight.",
            sentiment: "considers",
            desription: "Rewatched it three times already.",
            themes: ["Power", "Family", "Legacy"],
            rating: 10,
            likes: 512,
            reposts: 37,
            createdAt: Date().addingTimeInterval(-3600 * 26),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        // Breaking Bad near-duplicate
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 1396, // Breaking Bad
            contentType: "tv",
            reflection: "Hard to top its character arcs — meticulous writing from start to finish.",
            sentiment: "admires",
            desription: nil,
            themes: ["Morality", "Consequence", "Transformation"],
            rating: 10,
            likes: 905,
            reposts: 70,
            createdAt: Date().addingTimeInterval(-3600 * 80),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        ),
        // Stranger Things duplicate
        ArcModel(
            id: UUID(),
            userID: UUID(),
            contentID: 66732, // Stranger Things
            contentType: "tv",
            reflection: "Nostalgic without feeling lazy — the kid cast carries the emotional weight better than most adult ensembles.",
            sentiment: "relates",
            desription: nil,
            themes: ["Nostalgia", "Friendship", "Fear"],
            rating: 8,
            likes: 176,
            reposts: 12,
            createdAt: Date().addingTimeInterval(-3600 * 52),
            isSpoiler: false,
            hasLiked: false,
            hasReposted: false,
            hasSeen: false
        )
    ]
}
