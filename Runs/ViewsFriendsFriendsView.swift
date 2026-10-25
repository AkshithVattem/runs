//
//  FriendsView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var checkIns: [CheckIn]
    
    @State private var searchText = ""
    @State private var showAddFriend = false
    
    var activeFriends: [User] {
        // Filter users who have active check-ins
        let activeUserIDs = checkIns.filter { $0.isActive }.map { $0.userID }
        return users.filter { activeUserIDs.contains($0.id) }
    }
    
    var allFriends: [User] {
        users
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Active Friends Section
                if !activeFriends.isEmpty {
                    Section("At Courts Now") {
                        ForEach(activeFriends) { friend in
                            FriendRow(user: friend, isActive: true)
                        }
                    }
                }
                
                // All Friends
                Section("All Friends") {
                    if allFriends.isEmpty {
                        ContentUnavailableView(
                            "No Friends Yet",
                            systemImage: "person.2",
                            description: Text("Add friends to see who's playing")
                        )
                    } else {
                        ForEach(allFriends) { friend in
                            FriendRow(user: friend, isActive: activeFriends.contains(friend))
                        }
                    }
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
        }
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let user: User
    let isActive: Bool
    
    var body: some View {
        HStack {
            // Avatar
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.orange)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                
                if isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
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
            
            if isActive {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Friend View

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar is provided by searchable modifier
                
                // QR Code option
                VStack(spacing: 16) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                    
                    Text("Scan Friend's QR Code")
                        .font(.headline)
                    
                    Button("Show My QR Code") {
                        // Show QR code sheet
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Search results would go here
                
                Spacer()
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search by username")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FriendsView()
        .modelContainer(for: [User.self, CheckIn.self], inMemory: true)
}
