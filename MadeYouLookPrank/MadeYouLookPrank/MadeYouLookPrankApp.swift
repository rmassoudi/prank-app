import SwiftUI

// Personal, consent-based prank use only. This app captures only after the
// user explicitly starts the prank and stores photos locally on the device.
@main
struct MadeYouLookPrankApp: App {
    @StateObject private var camera = CameraController()
    @StateObject private var store = CaptureStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(camera)
                .environmentObject(store)
        }
    }
}
