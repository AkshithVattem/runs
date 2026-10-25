//
//  User.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var username: String
    var displayName: String
    var avatarURL: String?
    var bio: String?
    var skillLevel: Int // 1-5
    var positions: [String] // e.g., ["Guard", "Forward"]
    var heightInches: Int?
    var checkinVisibility: CheckinVisibility
    var createdAt: Date
    
    // Computed stats (would come from backend in production)
    var totalCheckIns: Int
    var hoursPlayed: Double
    var currentStreak: Int
    
    // Relationships
    @Relationship(deleteRule: .cascade) var checkIns: [CheckIn]?
    @Relationship(deleteRule: .cascade) var friendships: [Friendship]?
    
    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        avatarURL: String? = nil,
        bio: String? = nil,
        skillLevel: Int = 3,
        positions: [String] = [],
        heightInches: Int? = nil,
        checkinVisibility: CheckinVisibility = .friendsOnly,
        createdAt: Date = Date(),
        totalCheckIns: Int = 0,
        hoursPlayed: Double = 0,
        currentStreak: Int = 0
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.bio = bio
        self.skillLevel = skillLevel
        self.positions = positions
        self.heightInches = heightInches
        self.checkinVisibility = checkinVisibility
        self.createdAt = createdAt
        self.totalCheckIns = totalCheckIns
        self.hoursPlayed = hoursPlayed
        self.currentStreak = currentStreak
    }
}

enum CheckinVisibility: String, Codable {
    case everyone = "everyone"
    case friendsOnly = "friends"
    case privateMode = "private" // Ghost mode
}

enum PlayerPosition: String, CaseIterable, Codable {
    case pointGuard = "Point Guard"
    case shootingGuard = "Shooting Guard"
    case smallForward = "Small Forward"
    case powerForward = "Power Forward"
    case center = "Center"
}
