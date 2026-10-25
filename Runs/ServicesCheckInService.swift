//
//  CheckInService.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Observable
final class CheckInService {
    private let modelContext: ModelContext
    private let locationService: LocationService
    
    var currentCheckIn: CheckIn?
    var error: String?
    
    init(modelContext: ModelContext, locationService: LocationService) {
        self.modelContext = modelContext
        self.locationService = locationService
    }
    
    // MARK: - Check In
    
    func checkIn(
        userID: UUID,
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
        if let existing = try await getActiveCheckIn(for: userID) {
            throw CheckInError.alreadyCheckedIn(courtName: existing.court?.name ?? "a court")
        }
        
        // Create check-in
        let checkIn = CheckIn(
            userID: userID,
            courtID: court.id,
            status: status,
            partySize: partySize,
            method: method
        )
        
        modelContext.insert(checkIn)
        try modelContext.save()
        
        currentCheckIn = checkIn
        
        // Start monitoring for exit
        locationService.startMonitoring(court: court)
        
        return checkIn
    }
    
    // MARK: - Check Out
    
    func checkOut(checkIn: CheckIn, reason: CheckoutReason) async throws {
        checkIn.checkedOutAt = Date()
        checkIn.checkoutReason = reason
        
        try modelContext.save()
        
        if let courtID = checkIn.court?.id {
            locationService.stopMonitoring(courtID: courtID)
        }
        
        currentCheckIn = nil
    }
    
    func autoCheckOut(courtID: UUID, reason: CheckoutReason) async throws {
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.courtID == courtID && checkIn.checkedOutAt == nil
            }
        )
        
        if let checkIn = try modelContext.fetch(descriptor).first {
            try await checkOut(checkIn: checkIn, reason: reason)
        }
    }
    
    // MARK: - Update Status
    
    func updateStatus(_ status: CheckInStatus, for checkIn: CheckIn) throws {
        checkIn.status = status
        try modelContext.save()
    }
    
    func updatePartySize(_ size: Int, for checkIn: CheckIn) throws {
        checkIn.partySize = size
        try modelContext.save()
    }
    
    // MARK: - Queries
    
    func getActiveCheckIn(for userID: UUID) async throws -> CheckIn? {
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.userID == userID && checkIn.checkedOutAt == nil
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func getActiveCheckIns(for courtID: UUID) async throws -> [CheckIn] {
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.courtID == courtID && checkIn.checkedOutAt == nil
            },
            sortBy: [SortDescriptor(\.checkedInAt)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func getUserCheckInHistory(userID: UUID, limit: Int = 50) async throws -> [CheckIn] {
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.userID == userID
            },
            sortBy: [SortDescriptor(\.checkedInAt, order: .reverse)]
        )
        
        var fetchDescriptor = descriptor
        fetchDescriptor.fetchLimit = limit
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // MARK: - Validation
    
    func validateQRCode(_ qrData: String, for court: Court) -> Bool {
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
        
        // In production, validate HMAC signature
        // For MVP, simple secret check
        return !signature.isEmpty && !secret.isEmpty
    }
}

enum CheckInError: LocalizedError {
    case notInGeofence
    case alreadyCheckedIn(courtName: String)
    case invalidQRCode
    case courtNotFound
    
    var errorDescription: String? {
        switch self {
        case .notInGeofence:
            return "You must be at the court to check in"
        case .alreadyCheckedIn(let courtName):
            return "You're already checked in at \(courtName)"
        case .invalidQRCode:
            return "Invalid QR code"
        case .courtNotFound:
            return "Court not found"
        }
    }
}
