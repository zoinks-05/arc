//
//  UserModel.swift
//  Arc
//
//  Created by Ziyan Nadeem on 30/8/2026.
//

import Foundation

struct UserModel: Identifiable{
    
    let id: UUID
    
    var username: String
    var bio: String?
    var preferredGenres: [String]
    
    var followers: Int
    var following: Int
}
