import SwiftUI
import UIKit

struct PermissionDeniedView: View {
    let onTryAgain: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            FlameIconView()
                .frame(width: 92, height: 92)

            VStack(spacing: 10) {
                Text("Camera Needed")
                    .font(.largeTitle.bold())
                Text("Camera access is required for this prank. You can enable it in Settings, then try again.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Button(action: openSettings) {
                Label("Open Settings", systemImage: "gear")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.92, green: 0.14, blue: 0.28))
            .padding(.horizontal, 28)

            Button("Try Again", action: onTryAgain)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct FinishedView: View {
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            FlameIconView()
                .frame(width: 92, height: 92)

            Text("Prank complete.")
                .font(.largeTitle.bold())

            Text("Swipe up to close the app, or reset for another run.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Button("Reset", action: onReset)
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.92, green: 0.14, blue: 0.28))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

