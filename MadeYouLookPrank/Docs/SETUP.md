# Xcode Setup and Personal iPhone Install

## Requirements

- macOS with a current Xcode version that can build iOS 16+ apps
- An Apple Account added to Xcode
- A personal iPhone running iOS 16 or later
- USB cable or wireless device pairing

## Open the Project

1. Copy the `MadeYouLookPrank` folder to your Mac.
2. Open `MadeYouLookPrank/MadeYouLookPrank.xcodeproj` in Xcode.
3. Select the `MadeYouLookPrank` project in the navigator.
4. Select the `MadeYouLookPrank` app target.
5. Open `Signing & Capabilities`.
6. Enable `Automatically manage signing`.
7. Select your Apple Account team. A free account appears as a `Personal Team`.
8. Change the bundle identifier from `com.yourname.madeyoulook` to something unique, such as `com.yourlastname.madeyoulook`.

## Install on Your iPhone

1. Connect your iPhone to the Mac and tap Trust if prompted.
2. In Xcode, choose your iPhone as the run destination.
3. Press Run.
4. If iOS blocks first launch, open Settings on the iPhone and trust the developer profile shown for your Apple Account.
5. Launch the app from the home screen.

Apple documents the current device-running flow in its Xcode guide: Xcode adds your Apple Account, assigns a team, and with automatic signing creates the development provisioning profile when you run on a real device.

## Free Apple Developer Account Notes

- A free personal team can install apps for personal development and testing.
- A personal team cannot submit apps to the App Store.
- Xcode may require you to refresh or rebuild the app periodically.
- Camera behavior should be tested on a real iPhone; Simulator does not provide the same camera pipeline.

## Running Tests

1. Open the project in Xcode.
2. Select an iOS Simulator destination.
3. Choose Product > Test, or press Command-U.

The included tests cover the app-private photo store: save, metadata persistence, delete, and clear-all behavior.

## Got Me Button Behavior

iOS does not provide a public API for an app to close itself. The `Got Me!` button ends the prank flow and shows a finished screen; the user can then swipe up to close the app normally.

## Optional Icon Regeneration

The repository already includes generated app icon PNGs. If you edit the flame design and want to regenerate assets on Windows before copying to a Mac, run:

```powershell
.\Scripts\Generate-AppIcon.ps1
```

The in-app flame itself is SwiftUI code in `Views/Components/FlameIconView.swift`.
