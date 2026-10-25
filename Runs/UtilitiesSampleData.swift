//
//  SampleData.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

struct SampleData {
    
    /// Seeds the database with sample courts for testing
    static func seedCourts(modelContext: ModelContext) {
        // Check if we already have courts
        let descriptor = FetchDescriptor<Court>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            print("Courts already exist, skipping seed")
            return
        }
        
        let sampleCourts = [
            Court(
                name: "Mountain House Park",
                latitude: 37.7749,
                longitude: -122.4194,
                geofenceRadiusMeters: 150,
                isIndoor: false,
                numberOfHoops: 2,
                surfaceType: "Concrete",
                hasLights: true,
                hours: "6am - 10pm",
                photoURLs: [],
                qrSecret: "secret_mountain_house"
            ),
            Court(
                name: "Downtown Community Center",
                latitude: 37.7849,
                longitude: -122.4094,
                geofenceRadiusMeters: 100,
                isIndoor: true,
                numberOfHoops: 4,
                surfaceType: "Hardwood",
                hasLights: true,
                hours: "8am - 9pm",
                photoURLs: [],
                qrSecret: "secret_downtown_cc"
            ),
            Court(
                name: "Lakeside Recreation Area",
                latitude: 37.7649,
                longitude: -122.4294,
                geofenceRadiusMeters: 200,
                isIndoor: false,
                numberOfHoops: 3,
                surfaceType: "Asphalt",
                hasLights: false,
                hours: "Dawn - Dusk",
                photoURLs: [],
                qrSecret: "secret_lakeside"
            ),
            Court(
                name: "Westside Gym",
                latitude: 37.7549,
                longitude: -122.4394,
                geofenceRadiusMeters: 80,
                isIndoor: true,
                numberOfHoops: 2,
                surfaceType: "Hardwood",
                hasLights: true,
                hours: "6am - 11pm",
                photoURLs: [],
                qrSecret: "secret_westside"
            ),
            Court(
                name: "Riverside Courts",
                latitude: 37.7449,
                longitude: -122.3994,
                geofenceRadiusMeters: 150,
                isIndoor: false,
                numberOfHoops: 4,
                surfaceType: "Concrete",
                hasLights: true,
                hours: "24 hours",
                photoURLs: [],
                qrSecret: "secret_riverside"
            )
        ]
        
        for court in sampleCourts {
            modelContext.insert(court)
        }
        
        do {
            try modelContext.save()
            print("✅ Seeded \(sampleCourts.count) sample courts")
        } catch {
            print("❌ Error seeding courts: \(error)")
        }
    }
    
    /// Seeds a sample user for testing
    static func seedSampleUser(modelContext: ModelContext) -> User {
        let descriptor = FetchDescriptor<User>()
        if let existingUser = try? modelContext.fetch(descriptor).first {
            return existingUser
        }
        
        let user = User(
            username: "hooper123",
            displayName: "Jordan Lee",
            bio: "Ball is life 🏀",
            skillLevel: 4,
            positions: ["Point Guard", "Shooting Guard"],
            heightInches: 72,
            checkinVisibility: .friendsOnly,
            totalCheckIns: 42,
            hoursPlayed: 86.5,
            currentStreak: 5
        )
        
        modelContext.insert(user)
        
        do {
            try modelContext.save()
            print("✅ Seeded sample user: \(user.displayName)")
        } catch {
            print("❌ Error seeding user: \(error)")
        }
        
        return user
    }
    
    /// Seeds sample check-ins for demonstration
    static func seedSampleCheckIns(modelContext: ModelContext) {
        // Get courts and user
        let courtDescriptor = FetchDescriptor<Court>()
        let userDescriptor = FetchDescriptor<User>()
        
        guard let courts = try? modelContext.fetch(courtDescriptor),
              !courts.isEmpty,
              let user = try? modelContext.fetch(userDescriptor).first else {
            print("Cannot seed check-ins: missing courts or user")
            return
        }
        
        // Create some active check-ins
        let checkIn1 = CheckIn(
            userID: user.id,
            courtID: courts[0].id,
            status: .playing,
            partySize: 1,
            method: .qr,
            checkedInAt: Date().addingTimeInterval(-3600) // 1 hour ago
        )
        
        let checkIn2 = CheckIn(
            userID: UUID(), // Random player
            courtID: courts[0].id,
            status: .waiting,
            partySize: 2,
            method: .geofence,
            checkedInAt: Date().addingTimeInterval(-1800) // 30 min ago
        )
        
        let checkIn3 = CheckIn(
            userID: UUID(),
            courtID: courts[1].id,
            status: .playing,
            partySize: 1,
            method: .qr,
            checkedInAt: Date().addingTimeInterval(-7200) // 2 hours ago
        )
        
        modelContext.insert(checkIn1)
        modelContext.insert(checkIn2)
        modelContext.insert(checkIn3)
        
        do {
            try modelContext.save()
            print("✅ Seeded sample check-ins")
        } catch {
            print("❌ Error seeding check-ins: \(error)")
        }
    }
    
    /// Seeds all sample data
    static func seedAll(modelContext: ModelContext) {
        seedCourts(modelContext: modelContext)
        let _ = seedSampleUser(modelContext: modelContext)
        seedSampleCheckIns(modelContext: modelContext)
    }
}
