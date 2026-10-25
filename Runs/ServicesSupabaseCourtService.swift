//
//  SupabaseCourtService.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import Supabase
import CoreLocation
import Observation

@Observable
final class SupabaseCourtService {
    private let client = SupabaseConfig.shared
    
    var courts: [Court] = []
    var isLoading = false
    var error: String?
    
    // MARK: - Fetch Courts
    
    /// Fetch all approved courts
    func fetchCourts() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await client
            .from("courts")
            .select()
            .eq("status", value: "approved")
            .execute()
        
        courts = try decodeC courts(from: response.data)
    }
    
    /// Fetch nearby courts using PostGIS
    func fetchNearbyCourts(
        latitude: Double,
        longitude: Double,
        radiusMeters: Int = 10000
    ) async throws -> [CourtWithDistance] {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await client
            .rpc(
                "nearby_courts",
                params: [
                    "lat": latitude,
                    "lng": longitude,
                    "radius_meters": radiusMeters
                ]
            )
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([CourtWithDistance].self, from: response.data)
    }
    
    /// Get court by ID
    func getCourt(id: UUID) async throws -> Court {
        let response = try await client
            .from("courts")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
        
        return try decodeCourt(from: response.data)
    }
    
    // MARK: - Create Court
    
    /// Suggest a new court (requires moderation)
    func suggestCourt(
        name: String,
        latitude: Double,
        longitude: Double,
        isIndoor: Bool,
        numberOfHoops: Int,
        surfaceType: String?,
        hasLights: Bool,
        hours: String?,
        createdBy: UUID
    ) async throws -> Court {
        let courtData: [String: Any] = [
            "name": name,
            "location": "POINT(\(longitude) \(latitude))",
            "is_indoor": isIndoor,
            "num_hoops": numberOfHoops,
            "surface_type": surfaceType as Any,
            "has_lights": hasLights,
            "hours": hours as Any,
            "created_by": createdBy.uuidString,
            "status": "pending"
        ]
        
        let response = try await client
            .from("courts")
            .insert(courtData)
            .select()
            .single()
            .execute()
        
        return try decodeCourt(from: response.data)
    }
    
    // MARK: - Active Check-ins
    
    /// Get active check-ins at a court (respects privacy settings)
    func getActiveCheckIns(
        courtId: UUID,
        requestingUserId: UUID
    ) async throws -> [ActiveCheckIn] {
        let response = try await client
            .rpc(
                "active_checkins_at_court",
                params: [
                    "p_court_id": courtId.uuidString,
                    "p_requesting_user_id": requestingUserId.uuidString
                ]
            )
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([ActiveCheckIn].self, from: response.data)
    }
    
    // MARK: - Subscribe to Check-ins
    
    /// Subscribe to real-time check-in updates for a court
    func subscribeToCourtCheckIns(
        courtId: UUID,
        onChange: @escaping ([ActiveCheckIn]) -> Void
    ) async throws -> RealtimeChannel {
        let channel = await client.realtime.channel("court:\(courtId)")
        
        let subscription = await channel.on("postgres_changes", filter: ChannelFilter(
            event: "*",
            schema: "public",
            table: "check_ins",
            filter: "court_id=eq.\(courtId)"
        )) { message in
            Task {
                // Refetch active check-ins when any change occurs
                if let userId = try? await self.getCurrentUserId() {
                    let checkIns = try? await self.getActiveCheckIns(
                        courtId: courtId,
                        requestingUserId: userId
                    )
                    if let checkIns = checkIns {
                        onChange(checkIns)
                    }
                }
            }
        }
        
        try await channel.subscribe()
        return channel
    }
    
    // MARK: - Helper Methods
    
    private func decodeCourt(from data: Data) throws -> Court {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dict = dict else {
            throw CourtServiceError.decodingFailed
        }
        
        return try parseCourt(from: dict)
    }
    
    private func decodeCourts(from data: Data) throws -> [Court] {
        let decoder = JSONDecoder()
        let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        guard let array = array else {
            throw CourtServiceError.decodingFailed
        }
        
        return try array.map { try parseCourt(from: $0) }
    }
    
    private func parseCourt(from dict: [String: Any]) throws -> Court {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = dict["name"] as? String else {
            throw CourtServiceError.decodingFailed
        }
        
        // Parse PostGIS geography point
        var latitude = 0.0
        var longitude = 0.0
        
        if let location = dict["location"] as? String {
            // Parse POINT(lng lat) format
            let coords = location
                .replacingOccurrences(of: "POINT(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: " ")
            
            if coords.count == 2,
               let lng = Double(coords[0]),
               let lat = Double(coords[1]) {
                longitude = lng
                latitude = lat
            }
        }
        
        return Court(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            geofenceRadiusMeters: dict["geofence_radius_m"] as? Int ?? 150,
            isIndoor: dict["is_indoor"] as? Bool ?? false,
            numberOfHoops: dict["num_hoops"] as? Int ?? 1,
            surfaceType: dict["surface_type"] as? String,
            hasLights: dict["has_lights"] as? Bool ?? false,
            hours: dict["hours"] as? String,
            photoURLs: dict["photo_urls"] as? [String] ?? [],
            qrSecret: dict["qr_secret"] as? String,
            status: CourtStatus(rawValue: dict["status"] as? String ?? "approved") ?? .approved
        )
    }
    
    private func getCurrentUserId() async throws -> UUID {
        let session = try await client.auth.session
        // Convert to user ID from database
        let response = try await client
            .from("users")
            .select("id")
            .eq("auth_id", value: session.user.id)
            .single()
            .execute()
        
        let dict = try JSONSerialization.jsonObject(with: response.data) as? [String: Any]
        guard let idString = dict?["id"] as? String,
              let id = UUID(uuidString: idString) else {
            throw CourtServiceError.userNotFound
        }
        
        return id
    }
}

// MARK: - Supporting Types

struct CourtWithDistance: Codable, Identifiable {
    let id: UUID
    let name: String
    let distanceMeters: Double
    let latitude: Double
    let longitude: Double
    let isIndoor: Bool
    let numHoops: Int
    let hasLights: Bool
    let activeCheckinsCount: Int
    
    var distanceFormatted: String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters)) m"
        } else {
            let km = distanceMeters / 1000
            return String(format: "%.1f km", km)
        }
    }
    
    var distanceMiles: Double {
        distanceMeters * 0.000621371
    }
}

struct ActiveCheckIn: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let displayName: String
    let avatarUrl: String?
    let status: String
    let partySize: Int
    let checkedInAt: Date
    let durationSeconds: Int
    
    var checkInStatus: CheckInStatus {
        CheckInStatus(rawValue: status) ?? .playing
    }
    
    var durationFormatted: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

enum CourtServiceError: LocalizedError {
    case decodingFailed
    case userNotFound
    case courtNotFound
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "Failed to decode court data"
        case .userNotFound:
            return "User not found"
        case .courtNotFound:
            return "Court not found"
        }
    }
}
