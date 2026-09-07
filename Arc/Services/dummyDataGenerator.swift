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

        for i in 1...100 {
            users.append(
                UserModel(
                    id: UUID(),
                    username: "user\(i)",
                    bio: "User \(i) Dev Testing",
                    preferredGenres: [],
                    followers: Int.random(in: 0...5000),
                    following: Int.random(in: 0...1000)
                )
            )
        }

        // Content IDs for movies and TV shows
        let movies = [
            157336, // Interstellar
            238, // The Godfather
            27205, // Inception
            129, // Spirited Away
            372058, // Your Name
            603, // The Matrix
            155, // The Dark Knight
            13, // Forrest Gump
            680, // Pulp Fiction
            278, // The Shawshank Redemption
            424, // Schindler's List
            120, // The Lord of the Rings
            24428, // The Avengers
            335984, // Blade Runner 2049
            438631, // Dune
            569094, // Spider-Man: Across the Spider-Verse
            496243, // Parasite
            346698, // Barbie
            872585, // Oppenheimer
            4935 // Howl's Moving Castle
        ]

        let tvShows = [
            1396, // Breaking Bad
            1399, // Game of Thrones
            66732, // Stranger Things
            85937, // Demon Slayer
            1429, // Attack on Titan
            95479, // Jujutsu Kaisen
            94605, // Arcane
            84958, // Loki
            94997, // House of the Dragon
            100088, // The Last of Us
            60625, // Rick and Morty
            52814, // One Punch Man
            62715, // Dragon Ball Super
            95557, // Invincible
            1398, // The Sopranos
            1397, // The Walking Dead
            37854, // One Piece
            95403 // The Bear
        ]

        // Arcs
        var arcs: [ArcModel] = []

        let reflections = [
            "This completely changed how I looked at the story.",
            "I keep thinking about this long after watching it.",
            "The character development here is incredible.",
            "The ending really stayed with me.",
            "I did not expect to connect with this as much as I did.",
            "The visuals are doing so much of the storytelling here.",
            "This is one of those stories that gets better on a rewatch.",
            "The relationship between these characters is what made this work for me.",
            "I think the themes are much deeper than they initially appear.",
            "The atmosphere of this is incredible.",
            "This scene is probably the part I will remember most.",
            "The soundtrack makes this moment so much better.",
            "I understand why people consider this a classic.",
            "This had a much bigger emotional impact than I expected.",
            "The pacing actually works really well for this story.",
            "I completely understand why people love this.",
            "There is so much going on underneath the surface.",
            "The final moments completely changed my interpretation.",
            "This character is easily the most interesting part.",
            "I noticed something completely different on my second watch."
        ]

        let descriptions = [
            "Generated description.",
            "A reflection generated for development testing.",
            "Testing longer Arc descriptions.",
            "A generated reaction to this content.",
            "Development test Arc.",
            "A longer generated description for UI testing.",
            "Testing how this Arc appears in the feed.",
            "Generated content for interaction testing.",
            "Testing spoiler and non-spoiler content.",
            "A generated Arc for the demo dataset."
        ]

        let themes = [
            "Drama", "Family", "Identity", "Love", "Loss", "Power",
            "Friendship", "Ambition", "Fear", "Memory", "Time", "Isolation",
            "Justice", "Revenge", "Sacrifice", "Growth", "Morality", "Hope",
            "Freedom", "Conflict", "Humanity", "Coming of Age", "Trust",
            "Loneliness", "Control", "War", "Good vs Evil", "Obsession"
        ]

        // Keep sentiments exactly the same
        let sentiments = [
            "believes",
            "feels",
            "thinks"
        ]

        for _ in 1...300 {
            let isMovie = Bool.random()
            let contentID = isMovie ? movies.randomElement()! : tvShows.randomElement()!
            let contentType = isMovie ? "movie" : "tv"

            let arc = ArcModel(
                id: UUID(),
                userID: users.randomElement()!.id,
                contentID: contentID,
                contentType: contentType,
                reflection: reflections.randomElement()!,
                sentiment: sentiments.randomElement()!,
                desription: descriptions.randomElement()!,
                themes: Array(Set(themes.shuffled().prefix(Int.random(in: 2...5)))),
                rating: Int.random(in: 1...10),
                likes: Int.random(in: 0...2500),
                reposts: Int.random(in: 0...700),
                createdAt: Date().addingTimeInterval(TimeInterval(-Int.random(in: 0...7776000))),
                isSpoiler: Bool.random(),
                hasLiked: false,
                hasReposted: false,
                hasSeen: Bool.random()
            )

            arcs.append(arc)
        }

        // Comments
        var comments: [CommentModel] = []

        let commentTexts = [
            "I completely agree with this.",
            "This is such a good take.",
            "I never thought about it this way.",
            "The ending really got me.",
            "This part stayed with me too.",
            "I noticed the same thing.",
            "This deserves way more attention.",
            "I had the exact opposite reaction.",
            "The character development here is incredible.",
            "This scene is still stuck in my head.",
            "That is actually a really interesting interpretation.",
            "I need to rewatch this now.",
            "This is why I love this story.",
            "The symbolism is what got me.",
            "I didn't catch that the first time.",
            "Absolutely one of my favourite moments.",
            "This makes much more sense now.",
            "The soundtrack deserves more credit.",
            "That final scene was insane.",
            "This is exactly how I felt.",
            "I completely missed that.",
            "This is a really interesting way to look at it.",
            "I had the same reaction.",
            "That scene destroyed me.",
            "One of the best moments in the whole thing.",
            "I disagree, but I can see where you're coming from.",
            "This is exactly why I wanted to talk about this.",
            "I need to watch this again.",
            "Such an underrated part of the story.",
            "That character is so well written."
        ]

        for arc in arcs {
            for _ in 0..<Int.random(in: 4...12) {
                let comment = CommentModel(
                    id: UUID(),
                    arcID: arc.id,
                    userID: users.randomElement()!.id,
                    text: commentTexts.randomElement()!,
                    likes: Int.random(in: 0...300),
                    createdAt: Date().addingTimeInterval(TimeInterval(-Int.random(in: 0...5184000))),
                    hasLiked: false
                )

                comments.append(comment)
            }
        }

        // Replies
        var replies: [ReplyModel] = []

        let replyTexts = [
            "Exactly.",
            "Same here.",
            "I agree.",
            "That's what I thought too.",
            "Great point.",
            "I hadn't thought about it like that.",
            "This!",
            "Absolutely.",
            "I noticed that too.",
            "That's actually really interesting.",
            "Now I want to watch it again.",
            "Definitely.",
            "Couldn't agree more.",
            "That was my reaction too.",
            "I completely missed that.",
            "Yes, exactly.",
            "This makes so much sense.",
            "That's a good point.",
            "I was thinking the same thing.",
            "100% agree."
        ]

        for comment in comments {
            for _ in 0..<Int.random(in: 1...5) {
                let reply = ReplyModel(
                    id: UUID(),
                    commentID: comment.id,
                    userID: users.randomElement()!.id,
                    text: replyTexts.randomElement()!,
                    likes: Int.random(in: 0...180),
                    createdAt: Date().addingTimeInterval(TimeInterval(-Int.random(in: 0...5184000))),
                    hasLiked: false
                )

                replies.append(reply)
            }
        }

        return Dataset(users: users, arcs: arcs, comments: comments, replies: replies)
    }
}
