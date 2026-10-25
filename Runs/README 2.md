# 🏀 Runs - Find Pickup Basketball Games

> **Check the court before you go.**

A social iOS app that helps basketball players find games, see who's playing right now, and connect with other hoopers.

[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)](https://www.apple.com/ios)
[![Swift](https://img.shields.io/badge/swift-5.9-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## ✨ Features

### 🗺️ **Court Discovery**
- Map view showing all nearby basketball courts
- Live player count for each court
- Distance from your location
- Filter by indoor/outdoor

### 📊 **Activity Analytics**
- **Hourly activity graphs** - See when courts are busiest
- Peak time detection
- Historical trends
- Plan your visit

### ✅ **GPS-Verified Check-Ins**
- Can't fake your location
- Geofence validation (150m radius)
- Your name shows up for others
- Auto check-out when you leave

### 👥 **Social Features**
- **Tap any player** to view their profile
- Send friend requests
- Accept/decline requests
- Direct messaging with friends
- See who's at courts right now

### ⏱️ **Real-Time Everything**
- Live player counts
- Live session timers (updates every second)
- Real-time chat messages
- Instant friend notifications

### 👤 **Rich Profiles**
- Profile picture
- Name, height, position
- Total check-ins
- Hours played
- Current streak
- Most visited courts

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Supabase account (free)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/AkshithVattem/runs.git
cd runs
```

2. **Open in Xcode**
```bash
open Runs.xcodeproj
```

3. **Add Supabase Swift Package**
- File → Add Package Dependencies
- URL: `https://github.com/supabase/supabase-swift`
- Version: Up to Next Major (2.0.0)

4. **Set up Supabase backend**

Follow the [**Supabase Setup Guide**](SUPABASE_SETUP.md) (takes ~15 minutes):
- Create Supabase project
- Run SQL schema
- Update credentials in `ConfigSupabaseConfig.swift`
- Enable realtime

5. **Build & Run**
```bash
⌘B  # Build
⌘R  # Run
```

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [**FEATURES_COMPLETE.md**](FEATURES_COMPLETE.md) | Complete feature checklist |
| [**SUPABASE_SETUP.md**](SUPABASE_SETUP.md) | Backend setup guide (15 min) |
| [**QUICKSTART.md**](QUICKSTART.md) | Quick start guide |
| [**BUILD_FIX.md**](BUILD_FIX.md) | Troubleshooting |
| [**GITHUB_PUSH_GUIDE.md**](GITHUB_PUSH_GUIDE.md) | Deployment guide |
| [**LIVE_TIMER_FEATURE.md**](LIVE_TIMER_FEATURE.md) | Live timer implementation |

## 🎯 User Flow

```
1. Open app → Sign in with Google/Apple
2. Create profile (name, height, position, photo)
3. Allow location access
4. See map with nearby courts + player counts
5. Tap court → View activity graph + player list
6. Tap player name → View their profile
7. Add friend / Send message
8. Check in (GPS verifies you're there)
9. Your name shows up for others
```

## 🏗️ Architecture

### Tech Stack
- **SwiftUI** - Modern iOS UI framework
- **SwiftData** - Local data persistence
- **Supabase** - PostgreSQL + Realtime backend
- **PostGIS** - Geospatial queries
- **CoreLocation** - GPS & geofencing
- **VisionKit** - QR code scanning
- **Swift Charts** - Activity graphs
- **Combine** - Reactive programming

### Project Structure
```
Runs/
├── Models/              # SwiftData models
│   ├── User.swift
│   ├── Court.swift
│   ├── CheckIn.swift
│   └── ...
├── Services/            # Business logic
│   ├── LocationService.swift
│   ├── AuthService.swift
│   └── Supabase services
├── Views/
│   ├── Onboarding/     # Sign in → Profile → Location
│   ├── Map/            # Court discovery + graphs
│   ├── CheckIn/        # QR scanner + GPS
│   ├── Friends/        # Social features
│   ├── Chat/           # Messaging
│   └── Profile/        # User stats
└── Database/
    └── SUPABASE_SCHEMA.sql
```

## 📊 Database Schema

**8 Tables:**
- `users` - Player profiles, stats, settings
- `courts` - Basketball courts with PostGIS locations
- `check_ins` - Active/historical sessions
- `friendships` - Social graph with requests
- `conversations` - Chat containers
- `conversation_members` - Chat participants
- `messages` - Chat messages
- `reports` - Safety/moderation

**Special Features:**
- PostGIS for location queries
- Row Level Security (RLS) for privacy
- Realtime subscriptions
- Helper functions for nearby courts

## 🔐 Privacy & Security

- ✅ **Row Level Security (RLS)** - Database-level access control
- ✅ **Check-in Visibility** - Everyone / Friends Only / Ghost Mode
- ✅ **GPS Verification** - Location can't be faked
- ✅ **OAuth 2.0** - Secure authentication
- ✅ **No Location History** - Only current check-ins visible to others
- ✅ **Block Users** - Safety controls

## 🎨 Screenshots

_Coming soon - add screenshots here_

## 📈 Roadmap

### ✅ Phase 1 - MVP (Completed)
- Authentication (Google + Apple)
- Profile creation
- Court discovery with map
- GPS-verified check-ins
- Real-time player tracking
- Activity graphs
- Friends system with requests
- Direct messaging
- Player profile cards

### 🔄 Phase 2 - Enhanced Features (Next)
- [ ] Court reviews & ratings
- [ ] Game scheduling ("Run at 6pm")
- [ ] Photo uploads (avatars + court photos)
- [ ] Push notifications
- [ ] Apple Watch companion app
- [ ] Auto check-out Edge Function
- [ ] Court condition reports

### 🚀 Phase 3 - Growth (Future)
- [ ] Teams & tournaments
- [ ] Leaderboards
- [ ] Achievement badges
- [ ] Workout tracking
- [ ] Live Activities (Dynamic Island)
- [ ] Expand to other sports
- [ ] Gym partnerships

## 💡 Why Runs?

### The Problem
- Drive to the court → nobody's there
- No way to know if a run is worth going to
- Can't find pickup games easily
- Messy group texts to coordinate

### The Solution
- **Live court status** - See player count before you leave
- **Activity graphs** - Know peak times
- **GPS verification** - Accurate data
- **Social features** - Find and connect with hoopers

## 🤝 Contributing

Currently a solo project, but open to feedback! Feel free to:
- Report bugs via Issues
- Suggest features
- Submit pull requests (coming soon)

## 📄 License

Copyright © 2026 Akshith Vattem

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.

## 🙏 Acknowledgments

Built with:
- [Supabase](https://supabase.com) - Backend as a Service
- [PostGIS](https://postgis.net) - Geospatial extension
- [Swift Charts](https://developer.apple.com/documentation/charts) - Data visualization

## 📞 Contact

- **GitHub**: [@AkshithVattem](https://github.com/AkshithVattem)
- **Repository**: [runs](https://github.com/AkshithVattem/runs)

## 🔗 Links

- [Supabase Swift Client](https://github.com/supabase/supabase-swift)
- [Swift Package Manager](https://swift.org/package-manager/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

<div align="center">

**Check the court before you go. 🏀**

Built with ❤️ using SwiftUI & Supabase

⭐ Star this repo if you think it's cool!

</div>
