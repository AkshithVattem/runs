//
//  SupabaseCheckInService.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import Supabase
import Observation

@Observable
final class SupabaseCheckInService {
    private let client = SupabaseConfig.shared
    private let locationService: LocationService
    
    var currentCheckIn: CheckIn?
    var error: String?
    private var realtimeChannel: RealtimeChannel?
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    // MARK: - Check In
    
    func checkIn(
        userId: UUID,
        courtId: UUID,
        court: Court,
        method: CheckInMethod,
        status: CheckInStatus = .playing,
        partySize: Int = 1
    ) async throws -> CheckIn {
        // Validate geofence
        guard locationService.isLocationWithinGeofence(of: court) else {
            throw CheckInError.notInGeofence
        }
        
        // Check for existing active check-in
        if let existing = try? await getActiveCheckIn(for: userId) {
            throw CheckInError.alreadyCheckedIn(courtName: existing.court?.name ?? "a court")
        }
        
        // Create check-in in Supabase
        let checkInData: [String: Any] = [
            "user_id": userId.uuidString,
            "court_id": courtId.uuidString,
            "status": status.rawValue,
            "party_size": partySize,
            "method": method.rawValue
        ]
        
        let response = try await client
            .from("check_ins")
            .insert(checkInData)
            .select()
            .single()
            .execute()
        
        let checkIn = try decodeCheckIn(from: response.data)
        currentCheckIn = checkIn
        
        // Start monitoring for exit
        locationService.startMonitoring(court: court)
        
        // Subscribe to realtime updates
        try await subscribeToCheckInUpdates(userId: userId)
        
        return checkIn
    }
    
    // MARK: - Check Out
    
    func checkOut(
        checkInId: UUID,
        reason: CheckoutReason
    ) async throws {
        let updates: [String: Any] = [
            "checked_out_at": ISO8601DateFormatter().string(from: Date()),
            "checkout_reason": reason.rawValue
        ]
        
        try await client
            .from("check_ins")
            .update(updates)
            .eq("id", value: checkInId)
            .execute()
        
        currentCheckIn = nil
        
        // Stop location monitoring
        if let courtId = currentCheckIn?.courtID {
            locationService.stopMonitoring(courtID: courtId)
        }
        
        // Unsubscribe from realtime
        if let channel = realtimeChannel {
            await client.realtime.removeChannel(channel)
            realtimeChannel = nil
        }
    }
    
    // MARK: - Update Status
    
    func updateStatus(_ status: CheckInStatus, for checkInId: UUID) async throws {
        try await client
            .from("check_ins")
            .update(["status": status.rawValue])
            .eq("id", value: checkInId)
            .execute()
    }
    
    func updatePartySize(_ size: Int, for checkInId: UUID) async throws {
        try await client
            .from("check_ins")
            .update(["party_size": size])
            .eq("id", value: checkInId)
            .execute()
    }
    
    // MARK: - Queries
    
    func getActiveCheckIn(for userId: UUID) async throws -> CheckIn? {
        do {
            let response = try await client
                .from("check_ins")
                .select()
                .eq("user_id", value: userId)
                .is("checked_out_at", value: nil)
                .single()
                .execute()
            
            return try decodeCheckIn(from: response.data)
        } catch {
            // No active check-in found
            return nil
        }
    }
    
    func getCheckInHistory(userId: UUID, limit: Int = 50) async throws -> [CheckIn] {
        let response = try await client
            .from("check_ins")
            .select()
            .eq("user_id", value: userId)
            .order("checked_in_at", ascending: false)
            .limit(limit)
            .execute()
        
        return try decodeCheckIns(from: response.data)
    }
    
    // MARK: - Realtime Subscriptions
    
    private func subscribeToCheckInUpdates(userId: UUID) async throws {
        let channel = await client.realtime.channel("user_checkin:\(userId)")
        
        _ = await channel.on("postgres_changes", filter: ChannelFilter(
            event: "*",
            schema: "public",
            table: "check_ins",
            filter: "user_id=eq.\(userId)"
        )) { [weak self] message in
            Task {
                // Reload current check-in when updated
                self?.currentCheckIn = try? await self?.getActiveCheckIn(for: userId)
            }
        }
        
        try await channel.subscribe()
        realtimeChannel = channel
    }
    
    // MARK: - QR Code Validation
    
    func validateQRCode(_ qrData: String, for court: Court) async throws -> Bool {
        // Parse QR format: runs://checkin?court=<courtId>&sig=<hmac>
        guard let url = URL(string: qrData),
              url.scheme == "runs",
              url.host == "checkin",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return false
        }
        
        let courtIDString = queryItems.first(where: { $0.name == "court" })?.value
        let signature = queryItems.first(where: { $0.name == "sig" })?.value
        
        guard courtIDString == court.id.uuidString,
              let signature = signature,
              let secret = court.qrSecret else {
            return false
        }
        
        // Validate HMAC signature
        return validateHMAC(signature: signature, secret: secret, courtId: court.id.uuidString)
    }
    
    private func validateHMAC(signature: String, secret: String, courtId: String) -> Bool {
        // In production, implement proper HMAC-SHA256 validation
        // For MVP, simple check
        return !signature.isEmpty && !secret.isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func decodeCheckIn(from data: Data) throws -> CheckIn {
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dict = dict else {
            throw CheckInError.decodingFailed
        }
        
        return try parseCheckIn(from: dict)
    }
    
    private func decodeCheckIns(from data: Data) throws -> [CheckIn] {
        let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        guard let array = array else {
            throw CheckInError.decodingFailed
        }
        
        return try array.map { try parseCheckIn(from: $0) }
    }
    
    private func parseCheckIn(from dict: [String: Any]) throws -> CheckIn {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let userIdString = dict["user_id"] as? String,
              let userId = UUID(uuidString: userIdString),
              let courtIdString = dict["court_id"] as? String,
              let courtId = UUID(uuidString: courtIdString),
              let statusString = dict["status"] as? String,
              let status = CheckInStatus(rawValue: statusString),
              let methodString = dict["method"] as? String,
              let method = CheckInMethod(rawValue: methodString),
              let checkedInAtString = dict["checked_in_at"] as? String else {
            throw CheckInError.decodingFailed
        }
        
        let dateFormatter = ISO8601DateFormatter()
        guard let checkedInAt = dateFormatter.date(from: checkedInAtString) else {
            throw CheckInError.decodingFailed
        }
        
        var checkedOutAt: Date?
        if let checkedOutAtString = dict["checked_out_at"] as? String {
            checkedOutAt = dateFormatter.date(from: checkedOutAtString)
        }
        
        var checkoutReason: CheckoutReason?
        if let reasonString = dict["checkout_reason"] as? String {
            checkoutReason = CheckoutReason(rawValue: reasonString)
        }
        
        return CheckIn(
            id: id,
            userID: userId,
            courtID: courtId,
            status: status,
            partySize: dict["party_size"] as? Int ?? 1,
            method: method,
            checkedInAt: checkedInAt,
            checkedOutAt: checkedOutAt,
            checkoutReason: checkoutReason
        )
    }
}

// MARK: - Extended Errors

extension CheckInError {
    static let decodingFailed = CheckInError.invalidQRCode // Reuse for simplicity
}
