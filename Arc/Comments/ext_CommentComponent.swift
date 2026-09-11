//
//  ext_CommentComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 11/9/2026.
//
import SwiftUI

extension CommentComponent {

    var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(isExpanded ? 7 : 3)

                if needsSeeMore(description) {
                    Button(isExpanded ? "Show less" : "See more") {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(.secondary)

                    Text("No description provided")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Text(createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

     var inputBar: some View {
        VStack(spacing: 8) {
            Divider()
                .opacity(0.6)

            HStack(spacing: 8) {
                TextField(
                    isReplying ? "Replying..." : "Add a comment...",
                    text: $newComment,
                    axis: .vertical
                )
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
                .disabled(
                    isSubmitting ||
                    newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .glassEffect()
        .padding()
    }
 func submitContent() {
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !content.isEmpty, !isSubmitting else {
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            if let commentID = replyingCommentID {
                try submitReplyUseCase.execute(
                    content: content,
                    commentID: commentID,
                    dataStore: dataStore
                )

                replyingCommentID = nil
            } else {
                try submitCommentsUseCase.execute(
                    content: content,
                    arcID: arcID,
                    dataStore: dataStore
                )
            }

            newComment = ""

        } catch let error as CommentError {
            showErrorMessage(error.localizedDescription)

        } catch let error as ReplyError {
            showErrorMessage(error.localizedDescription)

        } catch {
            showErrorMessage("Your comment could not be submitted. Please try again.")
        }
    }

    func handleCommentLike(_ comment: CommentModel) {
        do {
            try toggleCommentsLikesUseCase.execute(
                commentID: comment.id,
                dataStore: dataStore
            )
        } catch let error as CommentError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your like could not be updated. Please try again.")
        }
    }

    func handleReplyLike(_ reply: ReplyModel) {
        do {
            try toggleRepliesLikesUseCase.execute(
                replyID: reply.id,
                dataStore: dataStore
            )
        } catch let error as ReplyError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your like could not be updated. Please try again.")
        }
    }

    func editComment() {
        guard let comment = selectedComment else {
            showErrorMessage(CommentError.commentNotFound.localizedDescription)
            return
        }

        do {
            try editCommentUseCase.execute(
                commentID: comment.id,
                dataStore: dataStore,
                newComment: editText
            )

            selectedComment = nil

        } catch let error as CommentError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your comment could not be edited. Please try again.")
        }
    }

    func editReply() {
        guard let reply = selectedReply else {
            showErrorMessage(ReplyError.replyNotFound.localizedDescription)
            return
        }

        do {
            try editReplyUseCase.execute(
                replyID: reply.id,
                dataStore: dataStore,
                newComment: editText
            )

            selectedReply = nil

        } catch let error as ReplyError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your reply could not be edited. Please try again.")
        }
    }

     func deleteComment() {
        guard let comment = selectedComment else {
            showErrorMessage(CommentError.commentNotFound.localizedDescription)
            return
        }

        do {
            try deleteCommentUseCase.execute(
                commentID: comment.id,
                dataStore: dataStore
            )

            selectedComment = nil

        } catch let error as CommentError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your comment could not be deleted. Please try again.")
        }
    }

     func deleteReply() {
        guard let reply = selectedReply else {
            showErrorMessage(ReplyError.replyNotFound.localizedDescription)
            return
        }

        do {
            try deleteReplyUseCase.execute(
                replyID: reply.id,
                dataStore: dataStore
            )

            selectedReply = nil

        } catch let error as ReplyError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Your reply could not be deleted. Please try again.")
        }
    }

    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    func getUser(for id: UUID) -> UserModel? {
        dataStore.users.first { $0.id == id }
    }

    func isOwnedByLocalUser(_ userID: UUID) -> Bool {
        getUser(for: userID)?.username.lowercased() == "localuser"
    }

    func needsSeeMore(_ text: String) -> Bool {
        text.split(separator: "\n").count > 3 || text.count > 160
    }

    
}

struct CommentRow: View {

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
            NavigationLink(
                destination: ProfileView(
                    dataStore: dataStore,
                    user: getUser(comment.userID)
                )
            ) {
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
                Divider()
                    .padding(.vertical, 8)

                ForEach(replies) { reply in
                    ReplyRow(
                        reply: reply,
                        dataStore: dataStore,
                        getUser: getUser,
                        onLike: {
                            onReplyLike(reply)
                        }
                    )
                    .onLongPressGesture {
                        if isOwnedByLocalUser(reply.userID) {
                            onLongPressReply(reply)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .onTapGesture(count: 2, perform: onDoubleTap)
        .onLongPressGesture {
            if isOwnedByLocalUser(comment.userID) {
                onLongPressComment(comment)
            }
        }
    }
}

struct ReplyRow: View {

    let reply: ReplyModel
    let dataStore: DummyDataStore
    let getUser: (UUID) -> UserModel?
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(
                destination: ProfileView(
                    dataStore: dataStore,
                    user: getUser(reply.userID)
                )
            ) {
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
