//
//  ReplyModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct ReplyModel: Identifiable {
    
    let id: UUID
    let commentID: UUID
    let userID: UUID
    
    var text: String
    var likes: Int
    var createdAt: Date
}
