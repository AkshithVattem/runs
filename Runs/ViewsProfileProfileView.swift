//
//  ProfileView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var checkIns: [CheckIn]
    
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    // Mock current user (first user or create one)
    var currentUser: User? {
        users.first
    }
    
    // Check if user has active check-in
    var activeCheckIn: CheckIn? {
        guard let user = currentUser else { return nil }
        return checkIns.first { $0.userID == user.id && $0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Active Session Banner (if checked in)
                    if let checkIn = activeCheckIn {
                        activeSessionBanner(for: checkIn)
                    }
                    
                    // Profile Header
                    profileHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Recent Activity
                    recentActivity
                    
                    // Settings
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: currentUser)
            }
        }
    }
    
    // MARK: - Active Session Banner
    
    @ViewBuilder
    private func activeSessionBanner(for checkIn: CheckIn) -> some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                
                Text("Currently Playing")
                    .font(.headline)
                    .foregroundStyle(.green)
                
                Spacer()
            }
            
            LiveSessionTimer(
                startDate: checkIn.checkedInAt,
                title: checkIn.court?.name ?? "Court"
            )
            
            Button {
                // Check out action
                Task {
                    checkIn.checkedOutAt = Date()
                    checkIn.checkoutReason = .manual
                    try? modelContext.save()
                }
            } label: {
                Label("Check Out", systemImage: "xmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Components
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                }
            
            if let user = currentUser {
                Text(user.displayName)
                    .font(.title2.bold())
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                Text("Guest User")
                    .font(.title2.bold())
            }
            
            Button {
                showEditProfile = true
            } label: {
                Text("Edit Profile")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(currentUser?.totalCheckIns ?? 0)",
                label: "Check-ins"
            )
            
            StatCard(
                icon: "clock.fill",
                value: String(format: "%.1f", currentUser?.hoursPlayed ?? 0),
                label: "Hours Played"
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(currentUser?.currentStreak ?? 0)",
                label: "Day Streak"
            )
            
            StatCard(
                icon: "basketball.fill",
                value: "N/A",
                label: "Fav Court"
            )
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    HStack {
                        Image(systemName: "basketball.fill")
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mountain House Park")
                                .font(.subheadline.bold())
                            Text("2 hours ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("1h 30m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                Text("Privacy Settings")
            } label: {
                SettingsRow(icon: "lock.fill", title: "Privacy", color: .blue)
            }
            
            NavigationLink {
                Text("Notification Settings")
            } label: {
                SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange)
            }
            
            NavigationLink {
                Text("About")
            } label: {
                SettingsRow(icon: "info.circle.fill", title: "About", color: .gray)
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var notificationsEnabled = true
    @State private var friendRequestsOnly = true
    @State private var checkInVisibility: CheckinVisibility = .friendsOnly
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Privacy") {
                    Picker("Check-in Visibility", selection: $checkInVisibility) {
                        Text("Everyone").tag(CheckinVisibility.everyone)
                        Text("Friends Only").tag(CheckinVisibility.friendsOnly)
                        Text("Private (Ghost Mode)").tag(CheckinVisibility.privateMode)
                    }
                    
                    Toggle("Friend Requests Only", isOn: $friendRequestsOnly)
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        // Sign out logic
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        // Delete account logic
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    let user: User?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var displayName: String
    @State private var bio: String
    @State private var skillLevel: Int
    
    init(user: User?) {
        self.user = user
        _displayName = State(initialValue: user?.displayName ?? "")
        _bio = State(initialValue: user?.bio ?? "")
        _skillLevel = State(initialValue: user?.skillLevel ?? 3)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Display Name", text: $displayName)
                    
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Basketball") {
                    Picker("Skill Level", selection: $skillLevel) {
                        Text("1 - Beginner").tag(1)
                        Text("2 - Casual").tag(2)
                        Text("3 - Intermediate").tag(3)
                        Text("4 - Competitive").tag(4)
                        Text("5 - Hooper").tag(5)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        if let user = user {
            user.displayName = displayName
            user.bio = bio
            user.skillLevel = skillLevel
            
            try? modelContext.save()
        }
        
        dismiss()
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self], inMemory: true)
}
