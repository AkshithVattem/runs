//
//  CheckIn.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class CheckIn {
    var id: UUID
    var userID: UUID
    var courtID: UUID
    var status: CheckInStatus
    var partySize: Int
    var method: CheckInMethod
    var checkedInAt: Date
    var checkedOutAt: Date?
    var checkoutReason: CheckoutReason?
    
    // Relationships
    var user: User?
    var court: Court?
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        courtID: UUID,
        status: CheckInStatus = .playing,
        partySize: Int = 1,
        method: CheckInMethod,
        checkedInAt: Date = Date(),
        checkedOutAt: Date? = nil,
        checkoutReason: CheckoutReason? = nil
    ) {
        self.id = id
        self.userID = userID
        self.courtID = courtID
        self.status = status
        self.partySize = partySize
        self.method = method
        self.checkedInAt = checkedInAt
        self.checkedOutAt = checkedOutAt
        self.checkoutReason = checkoutReason
    }
    
    // Computed properties
    var isActive: Bool {
        checkedOutAt == nil
    }
    
    var duration: TimeInterval {
        let endTime = checkedOutAt ?? Date()
        return endTime.timeIntervalSince(checkedInAt)
    }
    
    var durationFormatted: String {
        let duration = self.duration
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

enum CheckInStatus: String, Codable {
    case playing = "playing"
    case waiting = "waiting"
    case watching = "watching"
}

enum CheckInMethod: String, Codable {
    case qr = "qr"
    case geofence = "geofence"
}

enum CheckoutReason: String, Codable {
    case manual = "manual"
    case geofenceExit = "geofence_exit"
    case timeout = "timeout"
}
