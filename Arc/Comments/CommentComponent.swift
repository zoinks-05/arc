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
    
    @State  var newComment = ""
    @State  var replyingCommentID: UUID?

     let toggleCommentsLikesUseCase = CommentLikesUseCase()
     let toggleRepliesLikesUseCase = ReplyLikesUseCase()
     let submitCommentsUseCase = SubmitCommentUseCase()
     let submitReplyUseCase = SubmitReplyUseCase()
     let deleteCommentUseCase = CommentDeleteUseCase()
     let deleteReplyUseCase = ReplyDeleteUseCase()
     let editCommentUseCase = CommentEditUseCase()
     let editReplyUseCase = ReplyEditUseCase()

    @State  var selectedComment: CommentModel?
    @State  var selectedReply: ReplyModel?

    @State  var showCommentActions = false
    @State  var showReplyActions = false
    @State  var showDeleteCommentConfirmation = false
    @State  var showDeleteReplyConfirmation = false
    @State  var showEditComment = false
    @State  var showEditReply = false

    @State  var editText = ""
    @State  var isExpanded = false
    @State  var isSubmitting = false

    @State  var errorMessage: String?
    @State  var showError = false

     var comments: [CommentModel] {
        dataStore.comments.filter { $0.arcID == arcID }
    }

     var isReplying: Bool {
        replyingCommentID != nil
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView

                ScrollView {
                    Divider()
                        .padding(.vertical, 4)

                    if comments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 42))
                                .foregroundStyle(.secondary)

                            Text("No comments yet")
                                .font(.headline)

                            Text("The conversation is waiting for someone to start it.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(comments) { comment in
                            CommentRow(
                                comment: comment,
                                replies: dataStore.replies.filter {
                                    $0.commentID == comment.id
                                },
                                dataStore: dataStore,
                                getUser: getUser,
                                isOwnedByLocalUser: isOwnedByLocalUser,
                                onLike: {
                                    handleCommentLike(comment)
                                },
                                onReplyLike: { reply in
                                    handleReplyLike(reply)
                                },
                                onDoubleTap: {
                                    replyingCommentID = comment.id
                                },
                                onLongPressComment: { tapped in
                                    selectedComment = tapped
                                    showCommentActions = true
                                },
                                onLongPressReply: { tapped in
                                    selectedReply = tapped
                                    showReplyActions = true
                                }
                            )
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                inputBar
            }
            .confirmationDialog(
                "Comment Options",
                isPresented: $showCommentActions,
                titleVisibility: .visible
            ) {
                Button("Edit") {
                    editText = selectedComment?.text ?? ""
                    showEditComment = true
                }

                Button("Delete", role: .destructive) {
                    showDeleteCommentConfirmation = true
                }

                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Reply Options",
                isPresented: $showReplyActions,
                titleVisibility: .visible
            ) {
                Button("Edit") {
                    editText = selectedReply?.text ?? ""
                    showEditReply = true
                }

                Button("Delete", role: .destructive) {
                    showDeleteReplyConfirmation = true
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert("Edit Comment", isPresented: $showEditComment) {
                TextField("Comment", text: $editText)

                Button("Save") {
                    editComment()
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert("Edit Reply", isPresented: $showEditReply) {
                TextField("Reply", text: $editText)

                Button("Save") {
                    editReply()
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete Comment?", isPresented: $showDeleteCommentConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteComment()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this comment?")
            }
            .alert("Delete Reply?", isPresented: $showDeleteReplyConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteReply()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this reply?")
            }
            .alert("Something needs attention", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
        }
    }

 

}

