//
//  RunsApp.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

@main
struct RunsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Court.self,
            CheckIn.self,
            Friendship.self,
            Conversation.self,
            ConversationMember.self,
            Message.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Supabase authentication service
    @State private var authService = AuthService()
    
    // Location service
    @State private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .environment(locationService)
                .onAppear {
                    locationService.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root View (Handles Auth State)

struct RootView: View {
    @Environment(AuthService.self) private var authService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                SignInView()
            }
        }
    }
}
