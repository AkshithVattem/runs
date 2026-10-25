//
//  CourtActivityGraph.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import Charts

/// Shows court activity over the day with a line chart
struct CourtActivityGraph: View {
    let courtId: UUID
    @State private var activityData: [HourlyActivity] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Court Activity Today")
                    .font(.headline)
                
                Spacer()
                
                Text("Updated live")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if activityData.isEmpty {
                // Loading or empty state
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 180)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            Text("No activity data yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Chart(activityData) { item in
                    LineMark(
                        x: .value("Hour", item.hour),
                        y: .value("Players", item.playerCount)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Hour", item.hour),
                        y: .value("Players", item.playerCount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 3)) { value in
                        if let hour = value.as(Int.self) {
                            AxisValueLabel {
                                Text(formatHour(hour))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let count = value.as(Int.self) {
                                Text("\(count)")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Peak time indicator
            if let peakHour = activityData.max(by: { $0.playerCount < $1.playerCount }) {
                HStack {
                    Image(systemName: "clock.badge.checkmark")
                        .foregroundStyle(.orange)
                    Text("Peak time: \(formatHour(peakHour.hour)) (\(peakHour.playerCount) players)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            loadActivityData()
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour)\(period)"
    }
    
    private func loadActivityData() {
        // Generate sample data for demo
        // In production, fetch from Supabase
        activityData = (6...22).map { hour in
            HourlyActivity(
                hour: hour,
                playerCount: Int.random(in: 0...15)
            )
        }
    }
}

struct HourlyActivity: Identifiable {
    let id = UUID()
    let hour: Int
    let playerCount: Int
}

// MARK: - Player Profile Card (for tapping on players)

struct PlayerProfileCard: View {
    let player: ActiveCheckIn
    @Environment(\.dismiss) private var dismiss
    
    @State private var isFriend = false
    @State private var hasSentRequest = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        if let avatarUrl = player.avatarUrl {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.orange)
                                }
                        }
                        
                        VStack(spacing: 4) {
                            Text(player.displayName)
                                .font(.title2.bold())
                            
                            Text("@\(player.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Status badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Playing now • \(player.durationFormatted)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                    .padding(.top, 20)
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        if isFriend {
                            Button {
                                // Send message
                            } label: {
                                Label("Message", systemImage: "message.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.orange)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        } else {
                            Button {
                                sendFriendRequest()
                            } label: {
                                Label(
                                    hasSentRequest ? "Request Sent" : "Add Friend",
                                    systemImage: hasSentRequest ? "checkmark" : "person.badge.plus"
                                )
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(hasSentRequest ? Color.gray : Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(hasSentRequest)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats (if available)
                    // TODO: Add user stats from database
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func sendFriendRequest() {
        hasSentRequest = true
        // TODO: Send friend request to Supabase
    }
}

#Preview("Activity Graph") {
    CourtActivityGraph(courtId: UUID())
        .padding()
}

#Preview("Player Profile") {
    PlayerProfileCard(player: ActiveCheckIn(
        id: UUID(),
        userId: UUID(),
        username: "hooper123",
        displayName: "Jordan Lee",
        avatarUrl: nil,
        status: "playing",
        partySize: 1,
        checkedInAt: Date().addingTimeInterval(-3600),
        durationSeconds: 3600
    ))
}
