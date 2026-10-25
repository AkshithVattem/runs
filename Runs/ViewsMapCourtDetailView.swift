//
//  CourtDetailView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import SwiftData

struct CourtDetailView: View {
    let court: Court
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allCheckIns: [CheckIn]
    @State private var showCourtDiagram = true
    @State private var selectedPlayer: ActiveCheckIn?
    @State private var showPlayerProfile = false
    
    var activeCheckIns: [CheckIn] {
        allCheckIns.filter { $0.courtID == court.id && $0.isActive }
    }
    
    var playingCheckIns: [CheckIn] {
        activeCheckIns.filter { $0.status == .playing }
    }
    
    var waitingCheckIns: [CheckIn] {
        activeCheckIns.filter { $0.status == .waiting }
    }
    
    var watchingCheckIns: [CheckIn] {
        activeCheckIns.filter { $0.status == .watching }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    courtHeader
                    
                    // Quick Stats
                    quickStats
                    
                    // Court Activity Graph
                    CourtActivityGraph(courtId: court.id)
                        .padding(.horizontal)
                    
                    // Toggle View
                    Picker("View", selection: $showCourtDiagram) {
                        Text("Court Diagram").tag(true)
                        Text("List").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Court Diagram or List
                    if showCourtDiagram {
                        CourtDiagramView(
                            playingCheckIns: playingCheckIns,
                            waitingCheckIns: waitingCheckIns,
                            watchingCheckIns: watchingCheckIns
                        )
                        .frame(height: 500)
                        .padding()
                    } else {
                        checkInsList
                    }
                    
                    // Court Info
                    courtInfo
                }
            }
            .navigationTitle(court.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showPlayerProfile) {
                if let player = selectedPlayer {
                    PlayerProfileCard(player: player)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var courtHeader: some View {
        VStack(spacing: 8) {
            // Court photo placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "basketball.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
            
            HStack {
                Image(systemName: court.isIndoor ? "building.2" : "sun.max")
                Text(court.isIndoor ? "Indoor" : "Outdoor")
                
                Text("•")
                
                Image(systemName: "circle.grid.3x3")
                Text("\(court.numberOfHoops) hoop\(court.numberOfHoops == 1 ? "" : "s")")
                
                if court.hasLights {
                    Text("•")
                    Image(systemName: "light.max")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private var quickStats: some View {
        HStack(spacing: 20) {
            StatCard(
                icon: "person.2.fill",
                value: "\(activeCheckIns.count)",
                label: "Here Now"
            )
            
            StatCard(
                icon: "figure.basketball",
                value: "\(playingCheckIns.count / 10)",
                label: "Games"
            )
            
            StatCard(
                icon: "clock",
                value: "~\((waitingCheckIns.count + 9) / 10)",
                label: "Game Wait"
            )
        }
        .padding(.horizontal)
    }
    
    private var checkInsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !playingCheckIns.isEmpty {
                sectionHeader("Playing", color: .green)
                ForEach(playingCheckIns) { checkIn in
                    Button {
                        // Convert to ActiveCheckIn and show profile
                        selectedPlayer = convertToActiveCheckIn(checkIn)
                        showPlayerProfile = true
                    } label: {
                        CheckInRow(checkIn: checkIn)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if !waitingCheckIns.isEmpty {
                sectionHeader("Waiting / Next", color: .orange)
                ForEach(waitingCheckIns) { checkIn in
                    Button {
                        selectedPlayer = convertToActiveCheckIn(checkIn)
                        showPlayerProfile = true
                    } label: {
                        CheckInRow(checkIn: checkIn)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if !watchingCheckIns.isEmpty {
                sectionHeader("Watching", color: .blue)
                ForEach(watchingCheckIns) { checkIn in
                    Button {
                        selectedPlayer = convertToActiveCheckIn(checkIn)
                        showPlayerProfile = true
                    } label: {
                        CheckInRow(checkIn: checkIn)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if activeCheckIns.isEmpty {
                ContentUnavailableView(
                    "No one's here",
                    systemImage: "basketball",
                    description: Text("Be the first to check in!")
                )
                .frame(height: 200)
            }
        }
        .padding(.horizontal)
    }
    
    private func convertToActiveCheckIn(_ checkIn: CheckIn) -> ActiveCheckIn {
        ActiveCheckIn(
            id: checkIn.id,
            userId: checkIn.userID,
            username: "player\(checkIn.userID.uuidString.prefix(8))",
            displayName: "Player \(checkIn.userID.uuidString.prefix(8))",
            avatarUrl: nil,
            status: checkIn.status.rawValue,
            partySize: checkIn.partySize,
            checkedInAt: checkIn.checkedInAt,
            durationSeconds: Int(checkIn.duration)
        )
    }
    
    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.headline)
        }
        .padding(.top, 8)
    }
    
    private var courtInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
            
            if let surface = court.surfaceType {
                InfoRow(icon: "square.grid.2x2", text: surface)
            }
            
            if let hours = court.hours {
                InfoRow(icon: "clock", text: hours)
            }
            
            InfoRow(icon: "location", text: "Tap for directions")
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CheckInRow: View {
    let checkIn: CheckIn
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.gray)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Player \(checkIn.userID.uuidString.prefix(8))")
                    .font(.subheadline.bold())
                
                // Live timer
                LiveTimerRow(since: checkIn.checkedInAt)
            }
            
            Spacer()
            
            if checkIn.partySize > 1 {
                Text("+\(checkIn.partySize - 1)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Court.self, CheckIn.self, configurations: config)
    
    let court = Court(
        name: "Mountain House Park",
        latitude: 37.7749,
        longitude: -122.4194,
        isIndoor: false,
        numberOfHoops: 2,
        surfaceType: "Concrete",
        hasLights: true,
        hours: "6am - 10pm"
    )
    
    container.mainContext.insert(court)
    
    return CourtDetailView(court: court)
        .modelContainer(container)
}
