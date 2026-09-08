//
//  ArcModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct ArcModel: Identifiable, Codable {
    
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

