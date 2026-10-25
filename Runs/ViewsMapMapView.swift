//
//  MapView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courts: [Court]
    @Query private var checkIns: [CheckIn]
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCourt: Court?
    @State private var showCourtDetail = false
    @State private var showFilters = false
    
    // Filters
    @State private var filterIndoorOnly = false
    @State private var filterOutdoorOnly = false
    @State private var filterFriendsOnly = false
    
    // Mock current user ID (replace with real auth)
    let currentUserID = UUID() // In production, get from AuthService
    
    var filteredCourts: [Court] {
        courts.filter { court in
            if filterIndoorOnly && !court.isIndoor { return false }
            if filterOutdoorOnly && court.isIndoor { return false }
            // Add friends filter logic here
            return true
        }
    }
    
    // Check if current user has active check-in
    var activeCheckIn: CheckIn? {
        checkIns.first { $0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition) {
                    // User location
                    UserAnnotation()
                    
                    // Court markers
                    ForEach(filteredCourts) { court in
                        Annotation(court.name, coordinate: court.coordinate) {
                            CourtMapPin(court: court, checkInsCount: court.activeCheckInsCount)
                                .onTapGesture {
                                    selectedCourt = court
                                    showCourtDetail = true
                                }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                // Active session floating banner
                if let checkIn = activeCheckIn {
                    VStack {
                        Spacer()
                        activeSessionFloatingBanner(for: checkIn)
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Above tab bar
                    }
                }
                
                // Filter bar
                if showFilters {
                    VStack {
                        HStack {
                            FilterChip(title: "Indoor", isSelected: $filterIndoorOnly)
                            FilterChip(title: "Outdoor", isSelected: $filterOutdoorOnly)
                            FilterChip(title: "Friends", isSelected: $filterFriendsOnly)
                            Spacer()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Courts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showCourtDetail) {
                if let court = selectedCourt {
                    CourtDetailView(court: court)
                }
            }
        }
    }
    
    // MARK: - Active Session Banner
    
    @ViewBuilder
    private func activeSessionFloatingBanner(for checkIn: CheckIn) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Playing at \(checkIn.court?.name ?? "Court")")
                        .font(.subheadline.bold())
                        .lineLimit(1)
                }
                
                LiveTimerRow(since: checkIn.checkedInAt, showIcon: true)
            }
            
            Spacer()
            
            Button {
                if let court = checkIn.court {
                    selectedCourt = court
                    showCourtDetail = true
                }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}

// MARK: - Court Map Pin

struct CourtMapPin: View {
    let court: Court
    let checkInsCount: Int
    
    var activityColor: Color {
        switch court.activityLevel {
        case .empty: return .gray
        case .active: return .green
        case .full: return .orange
        case .crowded: return .red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(activityColor)
                .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Image(systemName: "basketball")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                
                Text("\(checkInsCount)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
            }
        }
        .shadow(radius: 3)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    MapView()
        .modelContainer(for: [Court.self, CheckIn.self], inMemory: true)
}
