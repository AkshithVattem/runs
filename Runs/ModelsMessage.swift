//
//  Message.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var type: ConversationType
    var name: String?
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var messages: [Message]?
    @Relationship(deleteRule: .cascade) var members: [ConversationMember]?
    
    init(
        id: UUID = UUID(),
        type: ConversationType,
        name: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.createdAt = createdAt
    }
}

@Model
final class ConversationMember {
    var id: UUID
    var conversationID: UUID
    var userID: UUID
    var lastReadAt: Date?
    
    var conversation: Conversation?
    var user: User?
    
    init(
        id: UUID = UUID(),
        conversationID: UUID,
        userID: UUID,
        lastReadAt: Date? = nil
    ) {
        self.id = id
        self.conversationID = conversationID
        self.userID = userID
        self.lastReadAt = lastReadAt
    }
}

@Model
final class Message {
    var id: UUID
    var conversationID: UUID
    var senderID: UUID
    var body: String?
    var imageURL: String?
    var sharedCourtID: UUID? // For court cards
    var createdAt: Date
    
    var conversation: Conversation?
    var sender: User?
    var sharedCourt: Court?
    
    init(
        id: UUID = UUID(),
        conversationID: UUID,
        senderID: UUID,
        body: String? = nil,
        imageURL: String? = nil,
        sharedCourtID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.body = body
        self.imageURL = imageURL
        self.sharedCourtID = sharedCourtID
        self.createdAt = createdAt
    }
}

enum ConversationType: String, Codable {
    case dm = "dm"
    case group = "group"
}
