//
//  Friendship.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class Friendship {
    var id: UUID
    var userID: UUID
    var friendID: UUID
    var status: FriendshipStatus
    var createdAt: Date
    
    // Relationships
    var user: User?
    var friend: User?
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        friendID: UUID,
        status: FriendshipStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.friendID = friendID
        self.status = status
        self.createdAt = createdAt
    }
}

enum FriendshipStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case blocked = "blocked"
}
