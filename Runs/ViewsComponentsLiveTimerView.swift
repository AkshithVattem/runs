//
//  LiveTimerView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import Combine

/// A view that displays a live, updating timer showing time elapsed since a date
struct LiveTimerView: View {
    let startDate: Date
    let format: TimerFormat
    
    @State private var currentTime = Date()
    
    // Timer that updates every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(since startDate: Date, format: TimerFormat = .compact) {
        self.startDate = startDate
        self.format = format
    }
    
    var body: some View {
        Text(formattedDuration)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
    }
    
    private var formattedDuration: String {
        let duration = currentTime.timeIntervalSince(startDate)
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        switch format {
        case .compact:
            // "1h 23m" or "23m"
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
            
        case .full:
            // "1h 23m 45s" or "23m 45s" or "45s"
            if hours > 0 {
                return "\(hours)h \(minutes)m \(seconds)s"
            } else if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            } else {
                return "\(seconds)s"
            }
            
        case .hoursMinutes:
            // "1:23" or "0:23"
            return String(format: "%d:%02d", hours, minutes)
            
        case .digital:
            // "1:23:45" or "0:23:45"
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

enum TimerFormat {
    case compact        // "1h 23m" or "23m"
    case full           // "1h 23m 45s"
    case hoursMinutes   // "1:23"
    case digital        // "1:23:45"
}

// MARK: - Variants for Different Contexts

/// Timer with icon for map pins
struct LiveTimerBadge: View {
    let startDate: Date
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 8))
            
            LiveTimerView(since: startDate, format: .compact)
                .font(.system(size: 9, weight: .bold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(backgroundColor)
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .shadow(radius: 2)
    }
}

/// Timer for list rows
struct LiveTimerRow: View {
    let startDate: Date
    let showIcon: Bool
    
    init(since startDate: Date, showIcon: Bool = true) {
        self.startDate = startDate
        self.showIcon = showIcon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: "clock")
                    .font(.caption2)
            }
            LiveTimerView(since: startDate, format: .full)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
}

/// Large timer for active session display
struct LiveSessionTimer: View {
    let startDate: Date
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LiveTimerView(since: startDate, format: .digital)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
                .monospacedDigit()
            
            Text("Active Session")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Compact Timer") {
    VStack(spacing: 20) {
        LiveTimerView(since: Date().addingTimeInterval(-3665), format: .compact)
            .font(.headline)
        
        LiveTimerView(since: Date().addingTimeInterval(-125), format: .compact)
            .font(.headline)
        
        LiveTimerView(since: Date().addingTimeInterval(-7325), format: .full)
            .font(.headline)
    }
    .padding()
}

#Preview("Timer Badge") {
    VStack(spacing: 20) {
        LiveTimerBadge(
            startDate: Date().addingTimeInterval(-3665),
            backgroundColor: .orange
        )
        
        LiveTimerBadge(
            startDate: Date().addingTimeInterval(-125),
            backgroundColor: .green
        )
    }
    .padding()
}

#Preview("Session Timer") {
    LiveSessionTimer(
        startDate: Date().addingTimeInterval(-3725),
        title: "Playing at Mountain House Park"
    )
    .padding()
}
