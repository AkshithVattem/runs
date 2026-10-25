//
//  MainTabView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var hasSeededData = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. Map Tab
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(0)
            
            // 2. Friends Tab
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(1)
            
            // 3. Check In Tab (center button)
            CheckInView()
                .tabItem {
                    Label("Check In", systemImage: "qrcode.viewfinder")
                }
                .tag(2)
            
            // 4. Chat Tab
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(3)
            
            // 5. Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(4)
        }
        .tint(.orange) // App accent color
        .onAppear {
            // Seed sample data on first launch
            if !hasSeededData {
                SampleData.seedAll(modelContext: modelContext)
                hasSeededData = true
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [User.self, Court.self, CheckIn.self], inMemory: true)
}
