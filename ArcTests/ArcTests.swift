//
//  ArcTests.swift
//  ArcTests
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import Testing
@testable import Arc
import Foundation

@Suite("Arc Logic Tests", .serialized)
struct ArcTests {
    
    func makeTestDataStore() -> DummyDataStore {
        let dataStore = DummyDataStore()
        dataStore.loadData()
        return dataStore
    }

    func localUser(in dataStore: DummyDataStore) throws -> UserModel {
        try #require(
            dataStore.users.first {
                $0.username.lowercased() == "localuser"
            }
        )
    }

    func localUserArc(in dataStore: DummyDataStore) throws -> ArcModel {
        let user = try localUser(in: dataStore)

        return try #require(
            dataStore.arcs.first {
                $0.userID == user.id
            }
        )
    }

    func anyArc(in dataStore: DummyDataStore) throws -> ArcModel {
        try #require(dataStore.arcs.first)
    }
    
    @Test("User can create a valid Arc")
    func userCanCreateArc() throws {

        let dataStore = makeTestDataStore()
        
        let useCase = CreateArcUseCase()

        let initialCount = dataStore.arcs.count

        try useCase.execute(
            reflection: "This movie left a lasting impression on me and made me think deeply.",
            description: "A memorable experience.",
            sentiment: "feels",
            themes: ["Drama"],
            rating: 8,
            isSpoiler: false,
            contentID: 550,
            contentType: "movie",
            dataStore: dataStore
        )

        #expect(dataStore.arcs.count == initialCount + 1)
    }
    
    @Test("Cannot create Arc with length < 50 characters")
    func cannotCreateArcwithLengthlessthan50Chars() throws {

        let dataStore = makeTestDataStore()
        let useCase = CreateArcUseCase()
        
        #expect(throws: Error.self) {
            try useCase.execute(
                reflection: "Too short",
                description: "",
                sentiment: "feels",
                themes: [],
                rating: 0,
                isSpoiler: false,
                contentID: 550,
                contentType: "movie",
                dataStore: dataStore
            )
        }
    }
    
    @Test("Cannot create Arc with score greater than 10")
    func cannotCreateArcwithScoregreaterthan10() throws {

        let dataStore = makeTestDataStore()
        let useCase = CreateArcUseCase()
        
        #expect(throws: Error.self) {
            try useCase.execute(
                reflection: String(repeating: "A", count: 50),
                description: "",
                sentiment: "feels",
                themes: [],
                rating: 11,
                isSpoiler: false,
                contentID: 550,
                contentType: "movie",
                dataStore: dataStore
            )
        }
    }
    
    @Test("User can edit an Arc")
    func userCanEditArc() throws {

        let dataStore = makeTestDataStore()

        let arc = try localUserArc(in: dataStore)

        let useCase = ArcEditUseCase()

        try useCase.execute(
            arcID: arc.id,
            dataStore: dataStore,
            newReflection: String(repeating: "B", count: 50),
            newDescription: "Updated description",
            newSentiment: "thinks",
            newThemes: ["Drama", "Thriller"],
            newRating: 9,
            newIsSpoiler: true
        )

        let updatedArc = try #require(
            dataStore.arcs.first {
                $0.id == arc.id
            }
        )

        #expect(
            updatedArc.reflection == String(repeating: "B", count: 50)
        )

        #expect(
            updatedArc.desription == "Updated description"
        )

        #expect(
            updatedArc.sentiment == "thinks"
        )

        #expect(
            updatedArc.themes == ["Drama", "Thriller"]
        )

        #expect(updatedArc.rating == 9)

        #expect(updatedArc.isSpoiler == true)
    }

    
    @Test("User can like and unlike an Arc")
    func userCanLikeAndUnlikeArc() throws {
        let dataStore = makeTestDataStore()

        let arc = try #require(dataStore.arcs.first)
        let useCase = ArcLikesUseCase()

        let originalLikes = arc.likes

        try useCase.execute(
            arcID: arc.id,
            dataStore: dataStore
        )

        let likedArc = try #require(
            dataStore.arcs.first { $0.id == arc.id }
        )

        #expect(likedArc.hasLiked == true)
        #expect(likedArc.likes == originalLikes + 1)

        try useCase.execute(
            arcID: arc.id,
            dataStore: dataStore
        )

        let unlikedArc = try #require(
            dataStore.arcs.first { $0.id == arc.id }
        )

        #expect(unlikedArc.hasLiked == false)
        #expect(unlikedArc.likes == originalLikes)
    }
    
    @Test("User can repost and unrepost an Arc")
    func userCanRepostAndUnrepostArc() throws {
        let dataStore = makeTestDataStore()
        
        let arc = try #require(dataStore.arcs.first)
        let useCase = ArcRepostUseCase()

        let originalReposts = arc.reposts

        try useCase.execute(
            arcID: arc.id,
            dataStore: dataStore
        )

        let repostedArc = try #require(
            dataStore.arcs.first { $0.id == arc.id }
        )

        #expect(repostedArc.hasReposted == true)
        #expect(repostedArc.reposts == originalReposts + 1)

        try useCase.execute(
            arcID: arc.id,
            dataStore: dataStore
        )

        let unrepostedArc = try #require(
            dataStore.arcs.first { $0.id == arc.id }
        )

        #expect(unrepostedArc.hasReposted == false)
        #expect(unrepostedArc.reposts == originalReposts)
    }
    
    @Test("User can create a comment and reply")
    func userCanCreateCommentAndReply() throws {
        let dataStore = makeTestDataStore()
        
        let arc = try #require(dataStore.arcs.first)

        let submitComment = SubmitCommentUseCase()
        let submitReply = SubmitReplyUseCase()

        try submitComment.execute(
            content: "This is a test comment for the Arc.",
            arcID: arc.id,
            dataStore: dataStore
        )

        let comment = try #require(
            dataStore.comments.last { $0.arcID == arc.id }
        )

        #expect(comment.arcID == arc.id)
        #expect(comment.text == "This is a test comment for the Arc.")

        try submitReply.execute(
            content: "This is a test reply to the comment.",
            commentID: comment.id,
            dataStore: dataStore
        )

        let reply = try #require(
            dataStore.replies.last { $0.commentID == comment.id }
        )

        #expect(reply.commentID == comment.id)
        #expect(reply.text == "This is a test reply to the comment.")

        // Intersection / relationship check
        let relatedComments = dataStore.comments.filter {
            $0.arcID == arc.id
        }

        let relatedReplies = dataStore.replies.filter {
            $0.commentID == comment.id
        }

        #expect(relatedComments.contains { $0.id == comment.id })
        #expect(relatedReplies.contains { $0.id == reply.id })
        #expect(reply.commentID == comment.id)
    }
    
    @Test("Deleting an Arc removes its comments and replies")
    func deletingArcRemovesCommentsAndReplies() throws {

        let dataStore = makeTestDataStore()

        let arc = try localUserArc(in: dataStore)

        let submitComment = SubmitCommentUseCase()
        let submitReply = SubmitReplyUseCase()
        let deleteArc = ArcDeleteUseCase()

        try submitComment.execute(
            content: "This comment will be removed with the Arc.",
            arcID: arc.id,
            dataStore: dataStore
        )

        let comment = try #require(
            dataStore.comments.last {
                $0.arcID == arc.id
            }
        )

        try submitReply.execute(
            content: "This reply will also be removed.",
            commentID: comment.id,
            dataStore: dataStore
        )

        #expect(
            dataStore.comments.contains {
                $0.id == comment.id
            }
        )

        #expect(
            dataStore.replies.contains {
                $0.commentID == comment.id
            }
        )

        try deleteArc.execute(
            arcID: arc.id,
            dataStore: dataStore
        )

        #expect(
            !dataStore.arcs.contains {
                $0.id == arc.id
            }
        )

        #expect(
            !dataStore.comments.contains {
                $0.arcID == arc.id
            }
        )

        #expect(
            !dataStore.replies.contains {
                $0.commentID == comment.id
            }
        )
    }
    
    @Test("Cannot submit an empty comment")
    func cannotSubmitEmptyComment() throws {
        let dataStore = makeTestDataStore()

        let arc = try #require(dataStore.arcs.first)
        let useCase = SubmitCommentUseCase()

        #expect(throws: CommentError.commentEmpty) {
            try useCase.execute(
                content: "",
                arcID: arc.id,
                dataStore: dataStore
            )
        }
    }
    
    @Test("Cannot reply to a deleted comment")
    func cannotReplyToDeletedComment() throws {
        let dataStore = makeTestDataStore()

        let arc = try #require(dataStore.arcs.first)

        let submitComment = SubmitCommentUseCase()
        let deleteComment = CommentDeleteUseCase()
        let submitReply = SubmitReplyUseCase()

        try submitComment.execute(
            content: "This comment will be deleted before replying.",
            arcID: arc.id,
            dataStore: dataStore
        )

        let comment = try #require(
            dataStore.comments.last { $0.arcID == arc.id }
        )

        try deleteComment.execute(
            commentID: comment.id,
            dataStore: dataStore
        )

        #expect(throws: ReplyError.parentCommentDeleted) {
            try submitReply.execute(
                content: "This reply should not be allowed.",
                commentID: comment.id,
                dataStore: dataStore
            )
        }
    }
}
