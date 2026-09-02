//
//  CommentComponet.swift
//  Arc
//
//  Created by Ziyan Nadeem on 2/9/2026.
//

import SwiftUI

struct CommentComponet: View {
    let description: String?
    let createdAt: Date
    @State var comments: [CommentModel]
    @State var replies: [ReplyModel]
    
    @State private var toggleCommentsLikesUseCase = CommentLikesUseCase()
    @State private var toggleRepliesLikesUseCase = ReplyLikesUseCase()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            
            if let description, !description.isEmpty {
                Text(description)
                    .font(.body)
            }
            
            Text(createdAt, style:.date)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ScrollView{
            
            Divider()
                .padding(8)
            
                ForEach(comments) { comment in
                    VStack(alignment: .leading, spacing: 8){
                        
                        Text(comment.text)
                            .font(.body)
                        
                        HStack(spacing: 12){
                            Text(comment.createdAt, style:.date)
                                .font(.subheadline)
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Text(String(comment.likes))
                            Image(systemName: comment.hasLiked ? "heart.fill" : "heart")
                                .onTapGesture {
                                    toggleCommentsLikesUseCase.execute(commentID: comment.id, comments: &comments)
                                }
                            
                        }
                        
                        Divider()
                            .padding(8)
                        
                        ForEach(replies.filter{ $0.commentID == comment.id}) { reply in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(reply.text)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                HStack(spacing:12){
                                    Text(reply.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                    Text(String(reply.likes))
                                    Image(systemName: reply.hasLiked ? "heart.fill" : "heart")
                                        .onTapGesture{
                                            toggleRepliesLikesUseCase.execute(replyID: reply.id, replys: &replies)
                                        }
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
