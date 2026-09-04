//
//  CommentComponent.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import SwiftUI

struct CommentComponet: View {
    let description: String?
    let createdAt: Date
    @State var dataStore : DummyDataStore
    @State var arcID: UUID
    @State var newComment: String = ""
    @State private var repliyingCommentID: UUID? = nil

    @State private var toggleCommentsLikesUseCase = CommentLikesUseCase()
    @State private var toggleRepliesLikesUseCase = ReplyLikesUseCase()
    @State private var submitCommentsUseCase = SubmitCommentUseCase()
    @State private var submitReplyUseCase = SubmitReplyUseCase()

    private var comments: [CommentModel] {
        dataStore.comments.filter { $0.arcID == arcID }
    }

    private var replies: [ReplyModel] {
        dataStore.replies
    }

    private var users: [UserModel] {
        dataStore.users
    }

    // Controls "See more" expansion in the header
    @State private var isExpanded: Bool = false
    @State private var isReplyExpanded: Bool = false
    @State private var isSubmittingComment: Bool = false
    @State private var isRepling: Bool = false

    @State private var user: UserModel?

    private func getUser(for id: UUID) -> UserModel? {
        users.first(where: { $0.id == id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            VStack(alignment: .leading, spacing: 6) {
                if let description, !description.isEmpty {
                    // Visible text with collapse/expand
                    ZStack(alignment: .bottomLeading) {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(isExpanded ? 7 : 3)

                        Text("A\nA\nA")
                            .font(.body)
                            .hidden()
                    }

                    // See more / Show less only when likely exceeding 3 lines
                    if needsSeeMore(description) {
                        Button {
                            withAnimation(.easeInOut) { isExpanded.toggle() }
                        } label: {
                            Text(isExpanded ? "Show less" : "See more")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // No description: still reserve about 3 lines of space
                    Text("A\nA\nA")
                        .font(.body)
                        .hidden()
                }

                Text(createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Comments list
            ScrollView {
                Divider()
                    .padding(.vertical, 4)

                ForEach(comments) { comment in
                    commentView(for: comment)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Divider().opacity(0.6)
                HStack(spacing: 8) {
                    TextField(isRepling ? "Replying" :"Add a comment...", text: $newComment, axis: .vertical)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .lineLimit(1...4)
                        .onSubmit(submitComment)
                        .submitLabel(.send)
                        .glassEffect()

                    Button(action: isRepling ? submitReply : submitComment) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .glassEffect(.regular, in: Circle())
                    }
                    .disabled(isSubmittingComment || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
            .glassEffect()
            .padding()
        }
    }

    @ViewBuilder
    private func commentView(for comment: CommentModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(getUser(for: comment.userID)?.username ?? "")
                .font(.headline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(comment.text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Text(comment.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: comment.hasLiked ? "heart.fill" : "heart")
                        .foregroundStyle(comment.hasLiked ? .red : .secondary)
                        .onTapGesture {
                            toggleCommentsLikesUseCase.execute(commentID: comment.id, dataStore: dataStore)
                        }
                    Text(String(comment.likes))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 8)

            ForEach(replies.filter { $0.commentID == comment.id }) { reply in
                replyView(for: reply)
                    .padding(.bottom)
            }
        }
        .onTapGesture(count: 2) {
            handleReplies(commentID: comment.id)
        }
    }

    @ViewBuilder
    private func replyView(for reply: ReplyModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getUser(for: reply.userID)?.username ?? "")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(reply.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Text(reply.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: reply.hasLiked ? "heart.fill" : "heart")
                        .foregroundStyle(reply.hasLiked ? .red : .secondary)
                        .onTapGesture {
                            toggleRepliesLikesUseCase.execute(replyID: reply.id, dataStore: dataStore)
                        }
                    Text(String(reply.likes))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 8)
            }
        }
    }
    
    private func handleReplies(commentID: UUID) {
        isRepling.toggle()
        repliyingCommentID = commentID
    }

    private func submitComment() {
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty, !isSubmittingComment else { return }
        isSubmittingComment = true
        submitCommentsUseCase.execute(
            content: content,
            arcID: arcID,
            dataStore: dataStore
        )
        newComment = ""
        isSubmittingComment = false
    }

    private func submitReply() {
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty, !isSubmittingComment else { return }
        guard let commentID = repliyingCommentID else { return }
        isSubmittingComment = true
        submitReplyUseCase.execute(
            content: content,
            commentID: commentID,
            dataStore: dataStore
        )
        newComment = ""
        isSubmittingComment = false
        repliyingCommentID = nil
        isRepling = false
    }

    // Simple heuristic: show "See more" when likely exceeding 3 body lines
    private func needsSeeMore(_ text: String) -> Bool {
        if text.split(separator: "\n").count > 3 { return true }
        return text.count > 160
    }
}
