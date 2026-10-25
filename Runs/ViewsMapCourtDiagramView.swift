//
//  CourtDiagramView.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI

struct CourtDiagramView: View {
    let playingCheckIns: [CheckIn]
    let waitingCheckIns: [CheckIn]
    let watchingCheckIns: [CheckIn]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Basketball court background
                BasketballCourt()
                    .stroke(Color.orange, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                
                // Player pins by zone
                
                // Playing zone (on court)
                ForEach(Array(playingCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                    PlayerPin(checkIn: checkIn, color: .green)
                        .position(
                            playingPosition(
                                index: index,
                                total: playingCheckIns.count,
                                in: geometry.size
                            )
                        )
                }
                
                // Waiting zone (sideline)
                ForEach(Array(waitingCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                    PlayerPin(checkIn: checkIn, color: .orange)
                        .position(
                            waitingPosition(
                                index: index,
                                in: geometry.size
                            )
                        )
                }
                
                // Watching zone (bleachers)
                ForEach(Array(watchingCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                    PlayerPin(checkIn: checkIn, color: .blue)
                        .position(
                            watchingPosition(
                                index: index,
                                in: geometry.size
                            )
                        )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Positioning Logic
    
    private func playingPosition(index: Int, total: Int, in size: CGSize) -> CGPoint {
        // Distribute players across the court
        let courtWidth = size.width * 0.7
        let courtHeight = size.height * 0.8
        
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // Split players between two teams (left and right halves)
        let isLeftTeam = index % 2 == 0
        let teamIndex = index / 2
        let teamSize = (total + 1) / 2
        
        let x: CGFloat
        if isLeftTeam {
            x = centerX - courtWidth / 4
        } else {
            x = centerX + courtWidth / 4
        }
        
        // Vertical spread
        let spacing = courtHeight / CGFloat(max(teamSize, 1) + 1)
        let y = centerY - courtHeight / 2 + spacing * CGFloat(teamIndex + 1)
        
        return CGPoint(x: x, y: y)
    }
    
    private func waitingPosition(index: Int, in size: CGSize) -> CGPoint {
        // Line up on the right sideline
        let x = size.width * 0.85
        let spacing: CGFloat = 50
        let startY = size.height * 0.3
        
        return CGPoint(x: x, y: startY + CGFloat(index) * spacing)
    }
    
    private func watchingPosition(index: Int, in size: CGSize) -> CGPoint {
        // Scattered in the "bleachers" area (top)
        let x = size.width * 0.2 + CGFloat(index % 3) * (size.width * 0.2)
        let y = size.height * 0.1
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Basketball Court Shape

struct BasketballCourt: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let courtRect = CGRect(
            x: rect.width * 0.15,
            y: rect.height * 0.1,
            width: rect.width * 0.7,
            height: rect.height * 0.8
        )
        
        // Outer boundary
        path.addRoundedRect(in: courtRect, cornerSize: CGSize(width: 8, height: 8))
        
        // Center circle
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        let circleRadius = min(courtRect.width, courtRect.height) * 0.15
        
        path.addEllipse(in: CGRect(
            x: centerX - circleRadius,
            y: centerY - circleRadius,
            width: circleRadius * 2,
            height: circleRadius * 2
        ))
        
        // Half court line
        path.move(to: CGPoint(x: centerX, y: courtRect.minY))
        path.addLine(to: CGPoint(x: centerX, y: courtRect.maxY))
        
        // Free throw circles (simplified)
        let ftCircleRadius = circleRadius * 0.8
        
        // Left circle
        path.addEllipse(in: CGRect(
            x: courtRect.minX + courtRect.width * 0.15 - ftCircleRadius,
            y: centerY - ftCircleRadius,
            width: ftCircleRadius * 2,
            height: ftCircleRadius * 2
        ))
        
        // Right circle
        path.addEllipse(in: CGRect(
            x: courtRect.maxX - courtRect.width * 0.15 - ftCircleRadius,
            y: centerY - ftCircleRadius,
            width: ftCircleRadius * 2,
            height: ftCircleRadius * 2
        ))
        
        return path
    }
}

// MARK: - Player Pin

struct PlayerPin: View {
    let checkIn: CheckIn
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
                
                // Avatar placeholder
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .shadow(radius: 2)
            
            // Live time badge
            LiveTimerBadge(
                startDate: checkIn.checkedInAt,
                backgroundColor: color
            )
        }
    }
}

#Preview {
    let playingCheckIns = (0..<10).map { i in
        CheckIn(
            userID: UUID(),
            courtID: UUID(),
            method: .qr,
            checkedInAt: Date().addingTimeInterval(-Double(i * 600))
        )
    }
    
    let waitingCheckIns = (0..<4).map { i in
        CheckIn(
            userID: UUID(),
            courtID: UUID(),
            status: .waiting,
            method: .geofence,
            checkedInAt: Date().addingTimeInterval(-Double(i * 300))
        )
    }
    
    let watchingCheckIns = (0..<3).map { i in
        CheckIn(
            userID: UUID(),
            courtID: UUID(),
            status: .watching,
            method: .geofence,
            checkedInAt: Date().addingTimeInterval(-Double(i * 200))
        )
    }
    
    return CourtDiagramView(
        playingCheckIns: playingCheckIns,
        waitingCheckIns: waitingCheckIns,
        watchingCheckIns: watchingCheckIns
    )
    .frame(height: 500)
    .padding()
}
