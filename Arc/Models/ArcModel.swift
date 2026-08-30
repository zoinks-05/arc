//
//  ArcModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct ArcModel: Identifiable {
    
    let id: UUID
    let userID: UUID
    let contentID: Int
    
    var reflection: String
    var desription: String?
    var themes: [String]
    
    var rating: Int
    var likes: Int
    var createdAt: Date
    
    var isPublic: Bool
    var isSpoiler: Bool
}
