//
//  AuthService.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import Supabase
import AuthenticationServices
import Observation

@Observable
final class AuthService {
    private let client = SupabaseConfig.shared
    
    var currentUser: User?
    var session: Session?
    var isAuthenticated: Bool {
        session != nil
    }
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Management
    
    /// Check if user has an existing session
    func checkSession() async {
        do {
            session = try await client.auth.session
            if let session = session {
                try await loadUserProfile(authId: session.user.id)
            }
        } catch {
            print("No active session: \(error.localizedDescription)")
            session = nil
            currentUser = nil
        }
    }
    
    /// Load user profile from database
    private func loadUserProfile(authId: UUID) async throws {
        let response = try await client
            .from("users")
            .select()
            .eq("auth_id", value: authId)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        currentUser = try decoder.decode(User.self, from: response.data)
    }
    
    // MARK: - Sign In with Apple
    
    /// Sign in with Apple
    @MainActor
    func signInWithApple(presentationAnchor: ASPresentationAnchor) async throws {
        // Request Apple ID credential
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate()
        controller.delegate = delegate
        controller.presentationContextProvider = PresentationContextProvider(window: presentationAnchor)
        controller.performRequests()
        
        // Wait for result
        let credential = try await withCheckedThrowingContinuation { continuation in
            delegate.continuation = continuation
        }
        
        // Exchange Apple credential for Supabase session
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidAppleCredential
        }
        
        session = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: tokenString
            )
        )
        
        // Check if user profile exists, create if not
        if let session = session {
            do {
                try await loadUserProfile(authId: session.user.id)
            } catch {
                // User doesn't exist, create profile
                try await createUserProfile(
                    authId: session.user.id,
                    email: credential.email ?? session.user.email ?? "",
                    fullName: credential.fullName
                )
            }
        }
    }
    
    // MARK: - Email Authentication
    
    /// Sign up with email and password
    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        guard let user = authResponse.user else {
            throw AuthError.signUpFailed
        }
        
        // Create user profile
        try await createUserProfile(
            authId: user.id,
            email: email,
            username: username,
            displayName: displayName
        )
        
        session = authResponse.session
        try await loadUserProfile(authId: user.id)
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        if let session = session {
            try await loadUserProfile(authId: session.user.id)
        }
    }
    
    // MARK: - Profile Creation
    
    private func createUserProfile(
        authId: UUID,
        email: String,
        username: String? = nil,
        displayName: String? = nil,
        fullName: PersonNameComponents? = nil
    ) async throws {
        // Generate username if not provided
        let finalUsername = username ?? generateUsername(from: email)
        let finalDisplayName = displayName ?? fullName?.formatted() ?? finalUsername
        
        let newUser = [
            "auth_id": authId.uuidString,
            "username": finalUsername,
            "display_name": finalDisplayName,
            "skill_level": 3,
            "checkin_visibility": "friends"
        ] as [String: Any]
        
        let response = try await client
            .from("users")
            .insert(newUser)
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        currentUser = try decoder.decode(User.self, from: response.data)
    }
    
    private func generateUsername(from email: String) -> String {
        let name = email.components(separatedBy: "@").first ?? "user"
        let random = Int.random(in: 1000...9999)
        return "\(name)\(random)"
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        try await client.auth.signOut()
        session = nil
        currentUser = nil
    }
    
    // MARK: - Update Profile
    
    func updateProfile(
        displayName: String? = nil,
        bio: String? = nil,
        skillLevel: Int? = nil,
        positions: [String]? = nil,
        heightInches: Int? = nil,
        checkinVisibility: CheckinVisibility? = nil
    ) async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        var updates: [String: Any] = [:]
        if let displayName = displayName { updates["display_name"] = displayName }
        if let bio = bio { updates["bio"] = bio }
        if let skillLevel = skillLevel { updates["skill_level"] = skillLevel }
        if let positions = positions { updates["positions"] = positions }
        if let heightInches = heightInches { updates["height_inches"] = heightInches }
        if let visibility = checkinVisibility { updates["checkin_visibility"] = visibility.rawValue }
        
        try await client
            .from("users")
            .update(updates)
            .eq("id", value: userId)
            .execute()
        
        // Reload profile
        if let session = session {
            try await loadUserProfile(authId: session.user.id)
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        // Delete user record (cascade deletes related data)
        try await client
            .from("users")
            .delete()
            .eq("id", value: userId)
            .execute()
        
        // Delete auth user
        // Note: This requires service_role key, should be done via Edge Function
        // For now, just sign out
        try await signOut()
    }
}

// MARK: - Supporting Types

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidAppleCredential
    case signUpFailed
    case profileCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .invalidAppleCredential:
            return "Invalid Apple credential"
        case .signUpFailed:
            return "Sign up failed. Please try again."
        case .profileCreationFailed:
            return "Failed to create user profile"
        }
    }
}

// MARK: - Sign in with Apple Delegate

@MainActor
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.invalidAppleCredential)
            return
        }
        continuation?.resume(returning: credential)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

private class PresentationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    let window: ASPresentationAnchor
    
    init(window: ASPresentationAnchor) {
        self.window = window
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window
    }
}

// MARK: - Supabase User Model Extension

extension User {
    /// Convert from Supabase database format
    static func from(supabaseData: [String: Any]) -> User? {
        guard let id = UUID(uuidString: supabaseData["id"] as? String ?? ""),
              let username = supabaseData["username"] as? String,
              let displayName = supabaseData["display_name"] as? String else {
            return nil
        }
        
        return User(
            id: id,
            username: username,
            displayName: displayName,
            avatarURL: supabaseData["avatar_url"] as? String,
            bio: supabaseData["bio"] as? String,
            skillLevel: supabaseData["skill_level"] as? Int ?? 3,
            positions: supabaseData["positions"] as? [String] ?? [],
            heightInches: supabaseData["height_inches"] as? Int,
            checkinVisibility: CheckinVisibility(rawValue: supabaseData["checkin_visibility"] as? String ?? "friends") ?? .friendsOnly,
            totalCheckIns: supabaseData["total_checkins"] as? Int ?? 0,
            hoursPlayed: supabaseData["hours_played"] as? Double ?? 0,
            currentStreak: supabaseData["current_streak"] as? Int ?? 0
        )
    }
}
