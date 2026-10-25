//
//  FriendsSystemView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import Supabase

/// Complete friends system with requests, accept/decline, and messaging
struct EnhancedFriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: FriendTab = .friends
    @State private var searchText = ""
    @State private var showAddFriend = false
    
    @State private var friends: [User] = []
    @State private var pendingRequests: [FriendRequest] = []
    @State private var sentRequests: [FriendRequest] = []
    
    enum FriendTab: String, CaseIterable {
        case friends = "Friends"
        case requests = "Requests"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Tab", selection: $selectedTab) {
                    ForEach(FriendTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                switch selectedTab {
                case .friends:
                    friendsList
                case .requests:
                    requestsList
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $searchText, prompt: "Search friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFriend = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    // MARK: - Friends List
    
    private var friendsList: some View {
        Group {
            if friends.isEmpty {
                ContentUnavailableView(
                    "No Friends Yet",
                    systemImage: "person.2",
                    description: Text("Add friends to see who's playing and chat with them")
                )
            } else {
                List {
                    ForEach(filteredFriends) { friend in
                        NavigationLink {
                            FriendProfileView(user: friend)
                        } label: {
                            FriendRowView(user: friend, isOnline: false)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var filteredFriends: [User] {
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { friend in
            friend.displayName.localizedCaseInsensitiveContains(searchText) ||
            friend.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Requests List
    
    private var requestsList: some View {
        List {
            if !pendingRequests.isEmpty {
                Section("Received") {
                    ForEach(pendingRequests) { request in
                        FriendRequestRow(
                            request: request,
                            onAccept: { acceptRequest(request) },
                            onDecline: { declineRequest(request) }
                        )
                    }
                }
            }
            
            if !sentRequests.isEmpty {
                Section("Sent") {
                    ForEach(sentRequests) { request in
                        SentRequestRow(request: request)
                    }
                }
            }
            
            if pendingRequests.isEmpty && sentRequests.isEmpty {
                ContentUnavailableView(
                    "No Friend Requests",
                    systemImage: "person.badge.clock",
                    description: Text("Friend requests will appear here")
                )
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Actions
    
    private func loadFriends() {
        // TODO: Load from Supabase
        // For now using empty arrays
    }
    
    private func acceptRequest(_ request: FriendRequest) {
        // TODO: Accept friend request in Supabase
        withAnimation {
            pendingRequests.removeAll { $0.id == request.id }
        }
    }
    
    private func declineRequest(_ request: FriendRequest) {
        // TODO: Decline friend request in Supabase
        withAnimation {
            pendingRequests.removeAll { $0.id == request.id }
        }
    }
}

// MARK: - Friend Row

struct FriendRowView: View {
    let user: User
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.orange)
                        }
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if isOnline {
                        Circle()
                            .fill(.green)
                            .frame(width: 14, height: 14)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            }
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                
                if isOnline {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("At court now")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("@\(user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Friend Request Row

struct FriendRequestRow: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.orange)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.fromUserName)
                        .font(.headline)
                    Text("@\(request.fromUsername)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button {
                    onAccept()
                } label: {
                    Text("Accept")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button {
                    onDecline()
                } label: {
                    Text("Decline")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Sent Request Row

struct SentRequestRow: View {
    let request: FriendRequest
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(request.toUserName)
                    .font(.subheadline.bold())
                Text("@\(request.toUsername)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("Pending")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.2))
                .foregroundStyle(.yellow.opacity(0.8))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Add Friend View

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "No Users Found",
                        systemImage: "person.slash",
                        description: Text("Try searching by username")
                    )
                } else if !searchResults.isEmpty {
                    List(searchResults) { user in
                        HStack {
                            FriendRowView(user: user, isOnline: false)
                            
                            Button {
                                sendFriendRequest(to: user)
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Find Friends",
                        systemImage: "magnifyingglass",
                        description: Text("Search for players by username")
                    )
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search username")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: searchText) { _, newValue in
                Task {
                    await searchUsers(query: newValue)
                }
            }
        }
    }
    
    private func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        // TODO: Search users in Supabase
        // For now, empty results
        searchResults = []
    }
    
    private func sendFriendRequest(to user: User) {
        // TODO: Send friend request to Supabase
        dismiss()
    }
}

// MARK: - Friend Profile View

struct FriendProfileView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header (similar to PlayerProfileCard)
                Text("Friend Profile for \(user.displayName)")
                    .font(.title)
                
                // TODO: Add full profile details
            }
            .padding()
        }
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Types

struct FriendRequest: Identifiable {
    let id: UUID
    let fromUserId: UUID
    let fromUserName: String
    let fromUsername: String
    let toUserId: UUID
    let toUserName: String
    let toUsername: String
    let createdAt: Date
}

#Preview {
    EnhancedFriendsView()
        .modelContainer(for: [User.self], inMemory: true)
}
