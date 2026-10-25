# Required Info.plist Entries

Add these entries to your `Info.plist` file for the app to work properly:

## Location Permissions

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Runs needs your location to show nearby courts and verify check-ins when you're at a court.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Runs needs background location access to automatically check you out when you leave the court, ensuring accurate headcounts for other players.</string>
```

## Camera Permission (for QR Scanner)

```xml
<key>NSCameraUsageDescription</key>
<string>Runs needs camera access to scan QR codes at basketball courts for quick check-ins.</string>
```

## Optional: Contacts (if implementing friend sync)

```xml
<key>NSContactsUsageDescription</key>
<string>Runs can help you find friends who also use the app by accessing your contacts (with your permission).</string>
```

## Background Modes

For geofence monitoring and auto check-out, enable Background Modes in your target's Signing & Capabilities:

1. Open your project settings
2. Select your app target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" and add "Background Modes"
5. Check:
   - ☑️ Location updates
   - ☑️ Background fetch (optional, for checking stale check-ins)

## Privacy Manifest (iOS 17+)

Starting with iOS 17, you may need to add a `PrivacyInfo.xcprivacy` file to declare:

- **NSPrivacyAccessedAPITypes**: Location services, Camera
- **NSPrivacyCollectedDataTypes**: User location (for court check-ins), User contact info (for profiles)
- **NSPrivacyTracking**: false (we don't track users across apps)

Example PrivacyInfo.xcprivacy:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryLocation</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>Purpose: Verify user presence at basketball courts for check-ins and display nearby courts</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeLocation</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>App functionality (court check-ins)</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeUserID</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>App functionality (user profiles and social features)</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

## App Store Requirements

When submitting to the App Store, ensure you:

1. ✅ Provide clear location permission purpose strings (above)
2. ✅ Implement in-app account deletion (in Settings)
3. ✅ Include UGC moderation (report/block in chat)
4. ✅ Set age rating to 13+ (COPPA compliance)
5. ✅ Consider forcing "Friends Only" visibility for users under 18

## Testing Location Features

### Simulator
1. Debug → Location → Custom Location
2. Enter coordinates: 37.7749, -122.4194 (near sample courts)
3. Use "Freeway Drive" for testing geofence enter/exit

### Physical Device
1. Build and run on device
2. When permission alert appears, grant "While Using" first
3. Later prompt for "Always Allow" for background geofencing
4. Visit a real court location or use a spoofing app for testing
