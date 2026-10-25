//
//  Court.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Court {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var geofenceRadiusMeters: Int
    var isIndoor: Bool
    var numberOfHoops: Int
    var surfaceType: String? // "Concrete", "Hardwood", "Asphalt"
    var hasLights: Bool
    var hours: String? // JSON string or simple text like "6am-10pm"
    var photoURLs: [String]
    var qrSecret: String? // For HMAC signing QR codes
    var status: CourtStatus
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var checkIns: [CheckIn]?
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        geofenceRadiusMeters: Int = 150,
        isIndoor: Bool = false,
        numberOfHoops: Int = 1,
        surfaceType: String? = nil,
        hasLights: Bool = false,
        hours: String? = nil,
        photoURLs: [String] = [],
        qrSecret: String? = nil,
        status: CourtStatus = .approved,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.geofenceRadiusMeters = geofenceRadiusMeters
        self.isIndoor = isIndoor
        self.numberOfHoops = numberOfHoops
        self.surfaceType = surfaceType
        self.hasLights = hasLights
        self.hours = hours
        self.photoURLs = photoURLs
        self.qrSecret = qrSecret
        self.status = status
        self.createdAt = createdAt
    }
    
    // Computed properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Get active check-ins count
    var activeCheckInsCount: Int {
        checkIns?.filter { $0.checkedOutAt == nil }.count ?? 0
    }
    
    // Activity level based on headcount
    var activityLevel: CourtActivityLevel {
        let count = activeCheckInsCount
        switch count {
        case 0: return .empty
        case 1...9: return .active
        case 10...15: return .full
        default: return .crowded
        }
    }
}

enum CourtStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
}

enum CourtActivityLevel {
    case empty      // Gray: 0
    case active     // Green: 1-9 (getting a run)
    case full       // Orange: 10-15 (full)
    case crowded    // Red: 16+ (long wait)
    
    var color: String {
        switch self {
        case .empty: return "gray"
        case .active: return "green"
        case .full: return "orange"
        case .crowded: return "red"
        }
    }
}
