# Build Fix Guide

## ⚡ Quick Fix (Do This First!)

The most common issue is that **files aren't added to your target**. Here's the immediate fix:

### Step 1: Add All New Files to Target

1. In Xcode's **Project Navigator** (left sidebar, ⌘1)
2. Click on each file that starts with `Models`, `Views`, `Services`, or `Utilities`
3. Open the **File Inspector** (right sidebar, ⌘⌥1)
4. Under **Target Membership**, check the box next to your app name (e.g., "Runs")

**Repeat for ALL these files:**
- `ModelsUser.swift`
- `ModelsCourt.swift`
- `ModelsCheckIn.swift`
- `ModelsFriendship.swift`
- `ModelsMessage.swift`
- `ServicesLocationService.swift`
- `ServicesCheckInService.swift`
- `ViewsMainTabView.swift`
- `ViewsMapMapView.swift`
- `ViewsMapCourtDetailView.swift`
- `ViewsMapCourtDiagramView.swift`
- `ViewsCheckInCheckInView.swift`
- `ViewsFriendsFriendsView.swift`
- `ViewsChatChatView.swift`
- `ViewsProfileProfileView.swift`
- `UtilitiesSampleData.swift`
- `AlternativeScanner.swift` (optional)

### Step 2: Clean and Rebuild

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Rebuild**: ⌘B

That should fix most issues!

---

## 1. Add All Files to Target

The files created might not be added to your app target. Fix this:

1. In Xcode's Project Navigator (⌘1), select each new file
2. In the File Inspector (⌘⌥1), check the **Target Membership** section
3. Ensure your app target (e.g., "Runs") is checked

**Files to check:**
- All files in `Models/` folder (User.swift, Court.swift, CheckIn.swift, etc.)
- All files in `Views/` folder
- All files in `Services/` folder
- All files in `Utilities/` folder

## 2. Organize Files into Groups

The files were created with flattened names (like `ModelsUser.swift`). Rename and organize them:

**Option A: Rename Files in Xcode**
1. Right-click `ModelsUser.swift` → Rename → `User.swift`
2. Create a Group: Right-click project → New Group → name it "Models"
3. Drag `User.swift` into the Models group
4. Repeat for all files

**Option B: Leave as-is**
The files will work fine with flat names, but it's less organized.

## 3. Fix Common Build Errors

### Error: "Static property 'qr' is not available"
✅ **FIXED** - Added `import Vision` to CheckInView.swift

### Error: "Instance method 'autoconnect()' is not available"
✅ **FIXED** - Added `import Combine` to LiveTimerView.swift

### Error: "Cannot find 'Court' in scope"
**Cause:** File not added to target
**Fix:** Add the file to target (step 1)

### Error: "Cannot find 'MapView' in scope"  
**Cause:** File not added to target
**Fix:** Add all View files to target

### Error: SwiftData relationship errors
**Cause:** Circular relationship issues
**Fix:** Make sure all model files are added to target and compiled first

## 4. Clean Build

After fixing file membership:

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Delete Derived Data**: 
   - Go to `~/Library/Developer/Xcode/DerivedData`
   - Delete the folder for your project
3. **Rebuild**: ⌘B

## 5. Fix File Organization (Recommended)

Create proper folder structure in Xcode:

```
Runs/
├── Models/
│   ├── User.swift          (rename ModelsUser.swift)
│   ├── Court.swift         (rename ModelsCourt.swift)
│   ├── CheckIn.swift       (rename ModelsCheckIn.swift)
│   ├── Friendship.swift    (rename ModelsFriendship.swift)
│   └── Message.swift       (rename ModelsMessage.swift)
├── Services/
│   ├── LocationService.swift
│   └── CheckInService.swift
├── Views/
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
├── RunsApp.swift
└── Info.plist
```

## 6. Verify Imports

Make sure each file has the correct imports:

**Models:** `import Foundation`, `import SwiftData`
**Views:** `import SwiftUI`, `import SwiftData`
**CheckInView:** `import SwiftUI`, `import SwiftData`, `import VisionKit`, `import Vision`
**MapView:** `import SwiftUI`, `import MapKit`, `import SwiftData`
**Services:** `import Foundation`, `import CoreLocation`, etc.

## 7. Check iOS Deployment Target

VisionKit's DataScannerViewController requires iOS 16+:

1. Select your project in Project Navigator
2. Select your target
3. General → Deployment Info → iOS 16.0 or later

## 8. If QR Scanner Still Fails

If you still get VisionKit errors, you can temporarily disable the QR scanner:

Replace the `DataScanner` usage in `CheckInView.swift` with a simple placeholder:

```swift
// MARK: - QR Scanner View (Simplified)
struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 100))
                    .foregroundStyle(.orange)
                
                Text("QR Scanner")
                    .font(.title)
                
                Text("In production, this will scan QR codes at courts.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
                
                // Simulate scan for testing
                Button("Simulate Scan (Testing)") {
                    onScan("runs://checkin?court=test&sig=test")
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
```

## 9. Common Xcode Issues

### "Multiple commands produce..."
**Cause:** File added to target multiple times
**Fix:** 
1. Select the file
2. File Inspector → Target Membership
3. Uncheck all except your main app target

### "Missing required module..."
**Cause:** Framework not linked
**Fix:**
1. Select project → Target → Build Phases
2. Link Binary With Libraries
3. Add: SwiftUI, SwiftData, MapKit, VisionKit, Vision, CoreLocation

## 10. Quick Test

After fixing, try building with just the essential files first:

1. Comment out the QR scanner temporarily
2. Build just the Map tab
3. Gradually enable other features

## Still Having Issues?

If build still fails:

1. **Start fresh:** File → New → Project, manually recreate structure
2. **Copy-paste code:** One file at a time, ensuring each builds
3. **Check Xcode version:** Make sure you're on Xcode 15+ for iOS 17 features

## Quick Fix: Remove Scanner Temporarily

In `CheckInView.swift`, replace the scanner button action:

```swift
Button {
    // showScanner = true  // Comment this out
    errorMessage = "QR scanner coming soon. Use nearby courts instead."
} label: {
    Label("Scan QR Code", systemImage: "qrcode.viewfinder")
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.orange)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

This lets you test the rest of the app while fixing the scanner.
