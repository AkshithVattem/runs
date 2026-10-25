# 🚀 Quick Start - Getting the App to Build

**Build failing? Follow this checklist:**

## ✅ Build Checklist

### 1. ADD ALL FILES TO TARGET (Most Common Issue!)
Open each file below, then in File Inspector (⌘⌥1), check "Runs" under Target Membership:

- [ ] ModelsUser.swift
- [ ] ModelsCourt.swift
- [ ] ModelsCheckIn.swift
- [ ] ModelsFriendship.swift
- [ ] ModelsMessage.swift
- [ ] ServicesLocationService.swift
- [ ] ServicesCheckInService.swift
- [ ] ViewsMainTabView.swift
- [ ] ViewsMapMapView.swift
- [ ] ViewsMapCourtDetailView.swift
- [ ] ViewsMapCourtDiagramView.swift
- [ ] ViewsCheckInCheckInView.swift
- [ ] ViewsFriendsFriendsView.swift
- [ ] ViewsChatChatView.swift
- [ ] ViewsProfileProfileView.swift
- [ ] ViewsComponentsLiveTimerView.swift
- [ ] UtilitiesSampleData.swift

### 2. CLEAN & BUILD
- [ ] Product → Clean Build Folder (⇧⌘K)
- [ ] Product → Build (⌘B)

### 3. ADD INFO.PLIST PERMISSIONS
- [ ] Privacy - Location When In Use Usage Description
- [ ] Privacy - Camera Usage Description

### 4. RUN
- [ ] Select iOS 17.0+ simulator
- [ ] Click Run (⌘R)

---

## 🎯 Quick Fix Instructions

### The #1 Issue: Files Not in Target

**What's happening:** Xcode doesn't know to compile the new files.

**How to fix (with pictures in words):**

```
XCODE WINDOW LAYOUT:
┌─────────────────────────────────────────────────────────────────┐
│ [Left Sidebar]     [Center: Code Editor]    [Right Sidebar]     │
│  Project Nav                                  File Inspector     │
│                                                                  │
│  📁 Runs                                      Target Membership  │
│    📄 RunsApp.swift                           ☑️ Runs           │
│    📄 ModelsUser.swift    ← SELECT THIS      ☐ RunsTests        │
│    📄 ModelsCourt.swift                                          │
│    ...                                                           │
└─────────────────────────────────────────────────────────────────┘
```

**Step-by-step:**
1. **LEFT SIDEBAR**: Click `ModelsUser.swift` (Project Navigator, ⌘1)
2. **RIGHT SIDEBAR**: Open File Inspector (⌘⌥1)
   - If not visible: View → Inspectors → Show File Inspector
3. **RIGHT SIDEBAR**: Scroll to "Target Membership"
4. **CHECK THE BOX** next to "Runs"
5. File should now compile!

**Pro tip:** Select multiple files (⌘-click) and add them all at once!

---

Follow these steps IN ORDER to get the Runs app building:

## Step 1: Add Files to Target ⭐ MOST IMPORTANT

**This is the #1 reason for build failures!**

All the new files need to be added to your Xcode target:

1. Open Xcode Project Navigator (⌘1)
2. Select each file listed below
3. In the File Inspector (⌘⌥1 or right sidebar)
4. Check "Target Membership" → Check "Runs" (or your target name)

**Files to add:**
```
✅ ModelsUser.swift
✅ ModelsCourt.swift
✅ ModelsCheckIn.swift
✅ ModelsFriendship.swift
✅ ModelsMessage.swift
✅ ServicesLocationService.swift
✅ ServicesCheckInService.swift
✅ ViewsMainTabView.swift
✅ ViewsMapMapView.swift
✅ ViewsMapCourtDetailView.swift
✅ ViewsMapCourtDiagramView.swift
✅ ViewsCheckInCheckInView.swift
✅ ViewsFriendsFriendsView.swift
✅ ViewsChatChatView.swift
✅ ViewsProfileProfileView.swift
✅ ViewsComponentsLiveTimerView.swift
✅ UtilitiesSampleData.swift
```

## Step 2: Clean Build Folder

1. Product → Clean Build Folder (⇧⌘K)
2. Or: Shift + Command + K

## Step 3: Build

1. Product → Build (⌘B)
2. Or: Command + B

## Step 4: If Still Failing

### Check iOS Deployment Target
1. Select project in Navigator
2. Select "Runs" target
3. General tab → Deployment Info
4. Set to **iOS 17.0** or later

### Check that frameworks are linked
1. Select project → Runs target → Build Phases
2. "Link Binary With Libraries" should include:
   - SwiftUI.framework
   - SwiftData.framework
   - MapKit.framework
   - CoreLocation.framework
   - VisionKit.framework
   - Vision.framework
   - AVFoundation.framework

These should be auto-linked, but verify.

## Step 5: Add Info.plist Permissions

Before running, add these to Info.plist:

1. Open `Info.plist` in Xcode
2. Right-click → Add Row
3. Add these keys:

```
Privacy - Location When In Use Usage Description
Value: Runs needs your location to show nearby courts and verify check-ins.

Privacy - Camera Usage Description
Value: Runs needs camera access to scan QR codes at basketball courts.
```

## Step 6: Run!

1. Select a simulator (iOS 17+) or your device
2. Click Run (⌘R) or Command + R
3. The app should launch with 5 sample courts on the map

## Common Errors & Fixes

### "Cannot find 'Court' in scope"
**Fix:** File not added to target (Step 1)

### "Cannot find 'MapView' in scope"
**Fix:** File not added to target (Step 1)

### "Static property 'qr' is not available"
**Fix:** Already fixed with Vision import. Clean build (Step 2)

### "Multiple commands produce..."
**Fix:** File added to target twice
1. Select file → File Inspector
2. Uncheck extra targets, leave only "Runs" checked

### Build succeeds but app crashes on launch
**Fix:** Missing Info.plist permissions (Step 5)

## Testing the App

Once running:

1. **Map Tab** - See 5 sample courts in SF Bay Area
2. **Check In Tab** - Use "Nearby Courts" to check in
3. **Profile Tab** - See sample user profile
4. **Friends Tab** - Currently empty (add friends later)
5. **Chat Tab** - Currently empty (send messages later)

## Need to Reset Data?

If you want to clear sample data:

1. Delete the app from simulator/device
2. Reinstall - sample data will re-seed

## Simulator Testing

The sample courts are located in San Francisco:
- Latitude: ~37.77
- Longitude: ~-122.41

To simulate being at a court:
1. Debug → Location → Custom Location
2. Enter: Latitude 37.7749, Longitude -122.4194
3. This places you near "Mountain House Park"

## Still Having Issues?

1. **Check Xcode version**: Requires Xcode 15.0+
2. **Check macOS version**: Requires macOS 13.5+ (Ventura)
3. **Delete Derived Data**:
   ```
   ~/Library/Developer/Xcode/DerivedData/
   ```
   Delete the "Runs-..." folder

4. **Restart Xcode**

5. If all else fails, see BUILD_FIX.md for detailed troubleshooting

## Next Steps After Building

Once the app runs:

1. ✅ Explore the map with sample courts
2. ✅ Try checking in to a court
3. ✅ View court detail with diagram
4. ✅ Edit your profile
5. 📖 Read README.md for feature documentation
6. 🔨 Start backend integration (see spec)

---

**Need help?** Check BUILD_FIX.md for detailed troubleshooting.
