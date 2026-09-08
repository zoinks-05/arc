//
//  CommentComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//
import SwiftUI

struct CommentComponent: View {
    let description: String?
    let createdAt: Date

    @State var dataStore: DummyDataStore
    @State var arcID: UUID
    @State private var newComment: String = ""
    @State private var replyingCommentID: UUID?

    private let toggleCommentsLikesUseCase = CommentLikesUseCase()
    private let toggleRepliesLikesUseCase = ReplyLikesUseCase()
    private let submitCommentsUseCase = SubmitCommentUseCase()
    private let submitReplyUseCase = SubmitReplyUseCase()
    private let deleteCommentUseCase = CommentDeleteUseCase()
    private let deleteReplyUseCase = ReplyDeleteUseCase()
    private let editCommentUseCase = CommentEditUseCase()
    private let editReplyUseCase = ReplyEditUseCase()
    
    @State private var selectedComment: CommentModel?
    @State private var selectedReply: ReplyModel?
    @State private var showCommentActions = false
    @State private var showReplyActions = false
    @State private var showDeleteCommentConfirmation = false
    @State private var showDeleteReplyConfirmation = false
    @State private var showEditComment = false
    @State private var showEditReply = false
    @State private var editText = ""
    @State private var isExpanded = false
    @State private var isSubmitting = false

    private var comments: [CommentModel] {
        let all: [CommentModel] = dataStore.comments
        return all.filter { $0.arcID == arcID }
    }
    private var isReplying: Bool { replyingCommentID != nil }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                
                ScrollView {
                    Divider().padding(.vertical, 4)
                    ForEach(comments) { comment in
                        // Keep inference simple with explicit locals.
                        let repliesForComment: [ReplyModel] = dataStore.replies.filter { $0.commentID == comment.id }
                        let likeAction: () -> Void = {
                            toggleCommentsLikesUseCase.execute(commentID: comment.id, dataStore: dataStore)
                        }
                        let doubleTapAction: () -> Void = {
                            replyingCommentID = comment.id
                        }
                        let longPressCommentAction: (CommentModel) -> Void = { tapped in
                            selectedComment = tapped
                            showCommentActions = true
                        }
                        let longPressReplyAction: (ReplyModel) -> Void = { tapped in
                            selectedReply = tapped
                            showReplyActions = true
                        }

                        CommentRow(
                            comment: comment,
                            replies: repliesForComment,
                            dataStore: dataStore,
                            getUser: getUser,
                            isOwnedByLocalUser: isOwnedByLocalUser,
                            onLike: likeAction,
                            onReplyLike: { reply in
                                toggleRepliesLikesUseCase.execute(replyID: reply.id, dataStore: dataStore)
                            },
                            onDoubleTap: doubleTapAction,
                            onLongPressComment: longPressCommentAction,
                            onLongPressReply: longPressReplyAction
                        )
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .safeAreaInset(edge: .bottom) { inputBar }
            .confirmationDialog("Comment Options", isPresented: $showCommentActions, titleVisibility: .visible) {
                Button("Edit") { editText = selectedComment?.text ?? ""; showEditComment = true }
                Button("Delete", role: .destructive) { showDeleteCommentConfirmation = true }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Reply Options", isPresented: $showReplyActions, titleVisibility: .visible) {
                Button("Edit") { editText = selectedReply?.text ?? ""; showEditReply = true }
                Button("Delete", role: .destructive) { showDeleteReplyConfirmation = true }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Edit Comment", isPresented: $showEditComment) {
                TextField("Comment", text: $editText)
                Button("Save") {
                    if let comment = selectedComment {
                        editCommentUseCase.execute(commentID: comment.id, dataStore: dataStore, newComment: editText)
                    }
                    selectedComment = nil
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Edit Reply", isPresented: $showEditReply) {
                TextField("Reply", text: $editText)
                Button("Save") {
                    if let reply = selectedReply {
                        // ReplyEditUseCase expects parameter name `newComment`
                        editReplyUseCase.execute(replyID: reply.id, dataStore: dataStore, newComment: editText)
                    }
                    selectedReply = nil
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete Comment?", isPresented: $showDeleteCommentConfirmation) {
                Button("Delete", role: .destructive) {
                    if let comment = selectedComment {
                        deleteCommentUseCase.execute(commentID: comment.id, dataStore: dataStore)
                    }
                    selectedComment = nil
                }
                Button("Cancel", role: .cancel) {}
            } message: { Text("Are you sure you want to delete this comment?") }
            .alert("Delete Reply?", isPresented: $showDeleteReplyConfirmation) {
                Button("Delete", role: .destructive) {
                    if let reply = selectedReply {
                        deleteReplyUseCase.execute(replyID: reply.id, dataStore: dataStore)
                    }
                    selectedReply = nil
                }
                Button("Cancel", role: .cancel) {}
            } message: { Text("Are you sure you want to delete this reply?") }
        }
    }

    // MARK: - Subviews
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(isExpanded ? 7 : 3)

                if needsSeeMore(description) {
                    Button(isExpanded ? "Show less" : "See more") {
                        withAnimation(.easeInOut) { isExpanded.toggle() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
            }

            Text(createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputBar: some View {
        VStack(spacing: 8) {
            Divider().opacity(0.6)
            HStack(spacing: 8) {
                TextField(isReplying ? "Replying..." : "Add a comment...", text: $newComment, axis: .vertical)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .lineLimit(1...4)
                    .onSubmit(submitContent)
                    .submitLabel(.send)
                    .glassEffect()

                Button(action: submitContent) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .glassEffect(.regular, in: Circle())
                }
                .disabled(isSubmitting || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .glassEffect()
        .padding()
    }

    // MARK: - Helpers & Actions
    private func getUser(for id: UUID) -> UserModel? {
        dataStore.users.first(where: { $0.id == id })
    }

    private func isOwnedByLocalUser(_ userID: UUID) -> Bool {
        getUser(for: userID)?.username.lowercased() == "localuser"
    }

    private func submitContent() {
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty, !isSubmitting else { return }

        isSubmitting = true
        if let replyID = replyingCommentID {
            submitReplyUseCase.execute(content: content, commentID: replyID, dataStore: dataStore)
            replyingCommentID = nil
        } else {
            submitCommentsUseCase.execute(content: content, arcID: arcID, dataStore: dataStore)
        }
        newComment = ""
        isSubmitting = false
    }

    private func needsSeeMore(_ text: String) -> Bool {
        text.split(separator: "\n").count > 3 || text.count > 160
    }
}

private struct CommentRow: View {
    let comment: CommentModel
    let replies: [ReplyModel]
    let dataStore: DummyDataStore
    let getUser: (UUID) -> UserModel?
    let isOwnedByLocalUser: (UUID) -> Bool
    let onLike: () -> Void
    let onReplyLike: (ReplyModel) -> Void
    let onDoubleTap: () -> Void
    let onLongPressComment: (CommentModel) -> Void
    let onLongPressReply: (ReplyModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: ProfileView(dataStore: dataStore, user: getUser(comment.userID))) {
                Text(getUser(comment.userID)?.username ?? "")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text(comment.text)
                .font(.body)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Text(comment.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: comment.hasLiked ? "heart.fill" : "heart")
                        .foregroundStyle(comment.hasLiked ? .red : .secondary)
                        .onTapGesture(perform: onLike)

                    Text("\(comment.likes)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !replies.isEmpty {
                Divider().padding(.vertical, 8)
                ForEach(replies) { reply in
                    ReplyRow(
                        reply: reply,
                        dataStore: dataStore,
                        getUser: getUser,
                        onLike: { onReplyLike(reply) }
                    )
                    .onLongPressGesture {
                        if isOwnedByLocalUser(reply.userID) { onLongPressReply(reply) }
                    }
                    .padding(.bottom)
                }
            }
        }
        .onTapGesture(count: 2, perform: onDoubleTap)
        .onLongPressGesture {
            if isOwnedByLocalUser(comment.userID) { onLongPressComment(comment) }
        }
    }
}

private struct ReplyRow: View {
    let reply: ReplyModel
    let dataStore: DummyDataStore
    let getUser: (UUID) -> UserModel?
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: ProfileView(dataStore: dataStore, user: getUser(reply.userID))) {
                Text(getUser(reply.userID)?.username ?? "")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text(reply.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Text(reply.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: reply.hasLiked ? "heart.fill" : "heart")
                        .foregroundStyle(reply.hasLiked ? .red : .secondary)
                        .onTapGesture(perform: onLike)

                    Text("\(reply.likes)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 8)
            }
        }
    }
}
