import SwiftUI

struct CameraCaptureView: View {
    @EnvironmentObject private var camera: CameraController
    let onCaptured: (PhotoCaptureResult) -> Void
    let onFailed: (Error) -> Void

    @State private var hasStarted = false
    @State private var countdown = 3
    @State private var status = "Getting your match ready..."

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.45), .clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Text(status)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                Spacer()

                Text("\(countdown)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 14)
                    .contentTransition(.numericText())
                    .accessibilityLabel("Countdown \(countdown)")

                Text("Smile. One local prank selfie is about to be captured.")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
            }
        }
        .task {
            await beginCaptureFlowOnce()
        }
        .onDisappear {
            camera.stopSession()
        }
    }

    private func beginCaptureFlowOnce() async {
        guard !hasStarted else { return }
        hasStarted = true

        do {
            try await camera.configureIfNeeded()
            camera.startSession()

            try await Task.sleep(nanoseconds: 500_000_000)

            for value in stride(from: 3, through: 1, by: -1) {
                await MainActor.run {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.7)) {
                        countdown = value
                        status = value == 1 ? "Capturing..." : "Getting your match ready..."
                    }
                }
                try await Task.sleep(nanoseconds: 650_000_000)
            }

            let result = try await camera.captureFrontPhoto()
            camera.stopSession()
            await MainActor.run {
                onCaptured(result)
            }
        } catch {
            camera.stopSession()
            await MainActor.run {
                onFailed(error)
            }
        }
    }
}

