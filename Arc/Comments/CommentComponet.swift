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
    let comments: [CommentModel]
    let replies: [ReplyModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            
            if let description, !description.isEmpty {
                Text(description)
                    .font(.body)
            }
            
            Text(createdAt, style:.relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CommentComponet(description: "Test", createdAt: , comments: <#T##[CommentModel]#>, replies: <#T##[ReplyModel]#>)
}
