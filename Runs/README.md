# Runs - Basketball Pickup App

A social app for pickup basketball that helps players see who's at which court right now, how long they've been there, and coordinate games with friends.

## 🏀 What We've Built

This is the **MVP foundation** for the Runs app, following the development roadmap from the spec.

### ✅ Completed Features

#### 1. **Data Models (SwiftData)**
- ✅ `User` - User profiles with stats, skill levels, positions
- ✅ `Court` - Basketball courts with location, geofencing, and metadata
- ✅ `CheckIn` - Active check-ins with status (playing/waiting/watching)
- ✅ `Friendship` - Friend connections and requests
- ✅ `Conversation` & `Message` - Chat infrastructure
- ✅ All models include proper relationships and computed properties

#### 2. **Core Services**
- ✅ `LocationService` - CoreLocation integration with geofencing
  - GPS tracking
  - Geofence enter/exit detection
  - Distance calculations
  - Authorization handling
- ✅ `CheckInService` - Check-in/check-out management
  - QR code validation
  - Geofence verification
  - Auto check-out support
  - Active check-in queries

#### 3. **User Interface**

**Map Tab** 📍
- ✅ MapKit integration with court markers
- ✅ Color-coded activity levels (gray/green/orange/red)
- ✅ Court pins showing live headcount
- ✅ Filters (Indoor/Outdoor/Friends)
- ✅ Court detail view with diagrams

**Court Detail View** 🏟️
- ✅ Court information and stats
- ✅ Live headcount and game count
- ✅ Court diagram with player positions
- ✅ Players organized by status zones:
  - Playing (on court)
  - Waiting (sideline)
  - Watching (bleachers)
- ✅ Toggle between diagram and list view
- ✅ Real-time session timers

**Check-In Tab** ✅
- ✅ QR code scanner (VisionKit integration)
- ✅ Nearby courts fallback
- ✅ Status picker (Playing/Waiting/Watching)
- ✅ Party size selector
- ✅ Check-in confirmation flow

**Friends Tab** 👥
- ✅ Friends list with live status
- ✅ "At Courts Now" section
- ✅ Add friend functionality
- ✅ Search by username

**Chat Tab** 💬
- ✅ Conversation list
- ✅ Direct messages UI
- ✅ Message bubbles
- ✅ New conversation creation

**Profile Tab** 👤
- ✅ User profile with stats
- ✅ Stats grid (check-ins, hours, streak)
- ✅ Recent activity feed
- ✅ Settings (Privacy, Notifications)
- ✅ Edit profile
- ✅ Check-in visibility controls

#### 4. **Sample Data**
- ✅ 5 sample courts (indoor/outdoor, various locations)
- ✅ Sample user profile
- ✅ Sample check-ins for testing
- ✅ Auto-seeding on first launch

## 🏗️ Architecture

**Tech Stack:**
- **SwiftUI** - Modern declarative UI
- **SwiftData** - Local data persistence
- **MapKit** - Native maps and location annotations
- **CoreLocation** - GPS and geofencing
- **VisionKit** - QR code scanning with DataScannerViewController
- **Swift Concurrency** - async/await for async operations

**Project Structure:**
```
Runs/
├── Models/              # SwiftData models
│   ├── User.swift
│   ├── Court.swift
│   ├── CheckIn.swift
│   ├── Friendship.swift
│   └── Message.swift
├── Services/            # Business logic layer
│   ├── LocationService.swift
│   └── CheckInService.swift
├── Views/               # SwiftUI views
│   ├── MainTabView.swift
│   ├── Map/
│   │   ├── MapView.swift
│   │   ├── CourtDetailView.swift
│   │   └── CourtDiagramView.swift
│   ├── CheckIn/
│   │   └── CheckInView.swift
│   ├── Friends/
│   │   └── FriendsView.swift
│   ├── Chat/
│   │   └── ChatView.swift
│   └── Profile/
│       └── ProfileView.swift
├── Utilities/
│   └── SampleData.swift
└── RunsApp.swift        # App entry point
```

## 📱 How to Use

### Map & Courts
1. Open the **Map** tab to see all courts
2. Tap a court pin to see details and who's there
3. Use filters to show Indoor/Outdoor courts only
4. View court diagram to see player positions by status

### Check In
1. Go to the **Check In** tab
2. Either:
   - Scan the QR code at a court
   - Select a nearby court from the list
3. Choose your status (Playing/Waiting/Watching)
4. Set party size if bringing friends
5. Confirm check-in

### Friends & Chat
1. Add friends from the **Friends** tab
2. See who's at courts in real-time
3. Message friends directly from **Chat**

### Profile
1. View your stats on **Profile** tab
2. Edit profile details
3. Manage privacy settings
4. Control check-in visibility

## 🔐 Privacy Features

- ✅ Check-in visibility settings:
  - Everyone
  - Friends Only (default)
  - Private/Ghost Mode
- ✅ Anonymous headcounts (ghost users still count)
- ✅ No precise GPS exposed (only "at Court X")
- ✅ Block/report functionality (UI placeholder)

## 🚧 Next Steps (Post-MVP)

Based on the spec, here's what to build next:

### Phase 1 - Backend Integration
- [ ] Replace SwiftData with Supabase/Firebase
- [ ] Implement real-time presence (Realtime subscriptions)
- [ ] User authentication (Sign in with Apple)
- [ ] Cloud storage for avatars and court photos
- [ ] Push notifications (APNs)

### Phase 2 - Advanced Check-In
- [ ] Background geofence monitoring
- [ ] Auto check-out on geofence exit
- [ ] Timeout job (4-hour max, "Still here?" at 3h)
- [ ] QR code HMAC signature validation
- [ ] Rate limiting and anti-abuse

### Phase 3 - Social Features
- [ ] Friend request system
- [ ] Contact sync (opt-in)
- [ ] QR codes for adding friends
- [ ] Friend notifications
- [ ] Activity feed

### Phase 4 - Chat Enhancements
- [ ] Court cards in chat
- [ ] Image sharing
- [ ] Read receipts
- [ ] Typing indicators
- [ ] Push notifications for messages

### Phase 5 - Data & Analytics
- [ ] Court busy hours graph
- [ ] Historical check-in data
- [ ] User stats calculation
- [ ] Streak tracking
- [ ] Most-visited court

### Phase 6 - Polish
- [ ] Onboarding flow
- [ ] Empty states
- [ ] Error handling
- [ ] Loading states
- [ ] Accessibility
- [ ] TestFlight beta

## 🎯 Key Metrics to Track

Once backend is integrated:
- Weekly active check-ins per court
- % auto vs. manual check-outs (data quality)
- Map opens → court visit conversion
- D7/D30 retention
- Friends per user (network density)

## ⚠️ Important Notes

### Location Permissions
Add these to `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Runs needs your location to show nearby courts and verify check-ins</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Runs needs background location access to automatically check you out when you leave the court</string>

<key>NSCameraUsageDescription</key>
<string>Runs needs camera access to scan QR codes at courts</string>
```

### Current Limitations
- **No backend** - All data is local-only with SwiftData
- **No real auth** - Using mock user IDs
- **No real-time sync** - Check-ins don't sync across devices
- **No push notifications** - Can't notify when friends check in
- **Limited geofencing** - Requires "Always" location permission for background monitoring

### Testing Tips
- Use the **Simulator** with simulated locations
- Sample courts use SF Bay Area coordinates (37.77, -122.41)
- Sample data seeds automatically on first launch
- Reset by deleting the app and reinstalling

## 📝 License

This is a demo/MVP implementation. See project owner for licensing.

---

**Built with ❤️ using SwiftUI, SwiftData, and MapKit**
