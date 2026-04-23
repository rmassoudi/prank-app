# Made You Look Prank

This is a complete, local-only SwiftUI prank app for iOS 16+.

Important boundary: this project intentionally does not covertly photograph people, suppress shutter indicators, or impersonate Tinder. The app uses a Tinder-adjacent flame visual and a dating-app style loading screen, but the user is clearly told that tapping Start will capture one selfie for a prank. Photos stay in a private app folder unless the device owner explicitly exports them.

## What It Includes

- SwiftUI app target for iOS 16+
- AVFoundation front-camera capture with permission handling
- Local app-private photo storage with timestamp manifest metadata
- Reveal screen with captured photo, flash/zoom/shake animation, and "MADE YOU LOOK!"
- Hidden owner gallery access by 3-second long press or triple-tap in the top-left corner
- Gallery grid with timestamps, delete, share, save to Photos, and Clear All
- SwiftUI flame icon implementation plus generated app icon assets
- Unit tests for the local capture store
- Setup guide for Xcode and personal-device sideloading

## Project Structure

```text
MadeYouLookPrank/
  MadeYouLookPrank.xcodeproj/
    project.pbxproj
  MadeYouLookPrank/
    Info.plist
    PrivacyInfo.xcprivacy
    Assets.xcassets/
    MadeYouLookPrankApp.swift
    Models/
    Services/
    Utilities/
    Views/
  MadeYouLookPrankTests/
    CaptureStoreTests.swift
  Scripts/
    Generate-AppIcon.ps1
  Docs/
    SETUP.md
    PRIVACY_AND_APP_STORE_NOTES.md
```

## Build

Open `MadeYouLookPrank.xcodeproj` in Xcode on macOS, choose the `MadeYouLookPrank` target, set your signing team, update the bundle identifier if needed, then run on a real iPhone. Camera capture is not fully testable in Simulator.

Detailed setup is in [Docs/SETUP.md](Docs/SETUP.md).

## Privacy

All captures are stored locally under the app's Application Support container. There is no networking code, no analytics, no cloud sync, and no third-party SDK.
