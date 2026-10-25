# 🚀 Push to GitHub Repository

## Your Repository
https://github.com/AkshithVattem/runs

---

## Quick Push Guide

### Option 1: First Time Setup (If not initialized)

```bash
# Navigate to your Xcode project directory
cd /path/to/your/Runs/project

# Initialize git (if not already)
git init

# Add your GitHub repository as remote
git remote add origin https://github.com/AkshithVattem/runs.git

# Add all files
git add .

# Commit with message
git commit -m "Initial commit: Complete Runs basketball app with all features

- Sign in with Google/Apple
- Profile creation with photo upload
- Location-based court discovery
- Court activity graphs
- GPS-verified check-ins
- Real-time player tracking
- Friends system with requests
- Direct messaging
- Supabase backend integration
- Live session timers
- Player profiles
- Complete onboarding flow"

# Push to GitHub
git push -u origin main

# If main doesn't exist, try master
git push -u origin master
```

---

### Option 2: If Already Initialized

```bash
# Check current status
git status

# Add all new files
git add .

# Commit changes
git commit -m "Add complete feature set: Onboarding, activity graphs, friend requests, Supabase integration"

# Push to GitHub
git push origin main
```

---

## Files to Commit (Checklist)

### ✅ Core App Files
- [ ] `RunsApp.swift` (updated)
- [ ] `ContentView.swift`
- [ ] `Info.plist` (with permissions)

### ✅ Models (8 files)
- [ ] `ModelsUser.swift`
- [ ] `ModelsCourt.swift`
- [ ] `ModelsCheckIn.swift`
- [ ] `ModelsFriendship.swift`
- [ ] `ModelsMessage.swift`
- [ ] `Item.swift` (can delete this old file)

### ✅ Services (5 files)
- [ ] `ServicesLocationService.swift`
- [ ] `ServicesCheckInService.swift`
- [ ] `ServicesAuthService.swift`
- [ ] `ServicesSupabaseCourtService.swift`
- [ ] `ServicesSupabaseCheckInService.swift`

### ✅ Config (1 file)
- [ ] `ConfigSupabaseConfig.swift`

### ✅ Views - Map (4 files)
- [ ] `ViewsMapMapView.swift`
- [ ] `ViewsMapCourtDetailView.swift`
- [ ] `ViewsMapCourtDiagramView.swift`
- [ ] `ViewsMapCourtActivityGraph.swift`

### ✅ Views - Other (9 files)
- [ ] `ViewsMainTabView.swift`
- [ ] `ViewsCheckInCheckInView.swift`
- [ ] `ViewsFriendsFriendsView.swift`
- [ ] `ViewsFriendsEnhancedFriendsView.swift`
- [ ] `ViewsChatChatView.swift`
- [ ] `ViewsProfileProfileView.swift`
- [ ] `ViewsAuthSignInView.swift`
- [ ] `ViewsOnboardingOnboardingFlow.swift`
- [ ] `ViewsComponentsLiveTimerView.swift`

### ✅ Utilities (1 file)
- [ ] `UtilitiesSampleData.swift`

### ✅ Database (1 file)
- [ ] `SUPABASE_SCHEMA.sql`

### ✅ Documentation (10+ files)
- [ ] `README.md`
- [ ] `README_FINAL.md`
- [ ] `FEATURES_COMPLETE.md`
- [ ] `SUPABASE_SETUP.md`
- [ ] `SUPABASE_INTEGRATION.md`
- [ ] `BUILD_FIX.md`
- [ ] `QUICKSTART.md`
- [ ] `LATEST_FIX.md`
- [ ] `LIVE_TIMER_FEATURE.md`
- [ ] `RUNS_BASKETBALL_SPEC.md`

### ✅ Optional
- [ ] `AlternativeScanner.swift` (backup QR scanner)
- [ ] `.gitignore` (recommended)

---

## Create .gitignore (Recommended)

Before committing, create a `.gitignore` file:

```bash
# Create .gitignore in project root
touch .gitignore
```

**Contents of .gitignore:**

```gitignore
# Xcode
.DS_Store
*/build/*
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
DerivedData/
*.hmap
*.ipa
*.xcuserstate
*.xcscmblueprint
*.xcworkspace
!default.xcworkspace
Pods/
Carthage/
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

# SwiftPackageManager
.build/
.swiftpm/

# Supabase (DO NOT COMMIT THESE IF YOU PUT REAL KEYS)
# Uncomment if you want to keep keys private:
# ConfigSupabaseConfig.swift

# CocoaPods
Pods/

# Accio
Dependencies/
.accio/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
iOSInjectionProject/
```

---

## Step-by-Step: Complete Process

### 1. Open Terminal

```bash
# Navigate to your Xcode project folder
cd ~/path/to/Runs
```

### 2. Check Git Status

```bash
git status
```

If you see "not a git repository", run:
```bash
git init
```

### 3. Add Remote (if not added)

```bash
git remote add origin https://github.com/AkshithVattem/runs.git

# Verify it was added
git remote -v
```

### 4. Add All Files

```bash
git add .
```

### 5. Check What Will Be Committed

```bash
git status
```

You should see all the new files listed in green.

### 6. Commit

```bash
git commit -m "Complete Runs app implementation

Features:
- Google/Apple Sign In
- Profile creation with photo upload  
- GPS-verified check-ins
- Real-time court activity graphs
- Friend requests system
- Direct messaging
- Live session timers
- Supabase backend integration
- Complete onboarding flow
- Player profile cards
- Tappable player names
- Enhanced friends system
- Court activity analytics

Tech Stack:
- SwiftUI + SwiftData
- Supabase (PostgreSQL + Realtime)
- PostGIS for geospatial queries
- CoreLocation for GPS
- VisionKit for QR scanning
- Swift Charts for analytics
"
```

### 7. Push to GitHub

```bash
# For main branch
git push -u origin main

# If that doesn't work, try master
git push -u origin master

# If it asks for login, enter GitHub username and Personal Access Token
```

---

## If You Need Authentication

GitHub requires a **Personal Access Token** instead of password:

### Create Token:
1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token (classic)"**
3. Give it a name: "Runs App Development"
4. Select scopes:
   - ✅ **repo** (all repo access)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

### Use Token:
When git asks for password, paste your **token** (not your GitHub password).

---

## Verify Upload

After pushing:

1. Go to: https://github.com/AkshithVattem/runs
2. You should see all your files!
3. Check that documentation is readable
4. Verify SQL file is there

---

## Update README on GitHub

Create a nice `README.md` in the root:

```markdown
# 🏀 Runs - Find Pickup Basketball Games

A social app that helps basketball players find games and connect with other hoopers.

## Features

✅ **Find Courts** - See all nearby basketball courts on a map
✅ **Live Activity** - Check who's playing right now before you go
✅ **GPS Check-In** - Verify you're at the court to check in
✅ **Activity Graphs** - See when courts are busiest
✅ **Friends System** - Add friends and message them
✅ **Real-Time Updates** - Everything syncs live

## Tech Stack

- **SwiftUI** - Modern iOS interface
- **Supabase** - PostgreSQL + Realtime backend
- **PostGIS** - Geospatial queries
- **CoreLocation** - GPS verification
- **Swift Charts** - Activity analytics

## Setup

See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for complete setup instructions.

## Documentation

- [Complete Features List](FEATURES_COMPLETE.md)
- [Supabase Setup Guide](SUPABASE_SETUP.md)
- [Build Troubleshooting](BUILD_FIX.md)
- [Quick Start](QUICKSTART.md)

## License

Copyright © 2026 Akshith Vattem

---

**Check the court before you go. 🏀**
```

---

## Common Issues

### Issue: "Permission denied (publickey)"

**Fix:** You need to set up SSH keys or use HTTPS with token

```bash
# Use HTTPS instead of SSH
git remote set-url origin https://github.com/AkshithVattem/runs.git
```

### Issue: "Repository not found"

**Fix:** Make sure the repository exists and you have access

1. Go to https://github.com/AkshithVattem/runs
2. If it doesn't exist, create it on GitHub first
3. Then retry the push

### Issue: "Updates were rejected"

**Fix:** Pull first, then push

```bash
git pull origin main --rebase
git push origin main
```

---

## Clean Commit History (Optional)

If you want a clean initial commit:

```bash
# Remove git history
rm -rf .git

# Start fresh
git init
git add .
git commit -m "Initial commit: Complete Runs basketball app"
git remote add origin https://github.com/AkshithVattem/runs.git
git push -u origin main --force
```

⚠️ **Warning:** Only do this if you're okay losing any existing history!

---

## After Pushing

### Add GitHub Badges (Optional)

Add to your README:

```markdown
![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)
```

### Set Repository Description

On GitHub:
1. Go to your repo
2. Click ⚙️ (Settings)
3. Add description: "Find pickup basketball games near you"
4. Add topics: `ios`, `swift`, `basketball`, `supabase`, `swiftui`

---

## Quick Command Summary

```bash
cd /path/to/Runs
git init
git remote add origin https://github.com/AkshithVattem/runs.git
git add .
git commit -m "Initial commit: Complete Runs basketball app"
git push -u origin main
```

**That's it!** Your code will be on GitHub. 🎉

---

## Next Steps After Push

1. ✅ Add a nice screenshot to README
2. ✅ Add your logo to repository
3. ✅ Create a LICENSE file
4. ✅ Set up GitHub Actions (optional)
5. ✅ Enable GitHub Pages for documentation
6. ✅ Star your own repo! ⭐

---

**Need help?** Check the GitHub docs: https://docs.github.com/en/get-started
