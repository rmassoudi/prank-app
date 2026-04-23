import SwiftUI

private enum AppScreen {
    case loading
    case consent
    case capture
    case permissionDenied
    case reveal(CapturedPhoto)
    case finished
}

struct RootView: View {
    @EnvironmentObject private var camera: CameraController
    @EnvironmentObject private var store: CaptureStore
    @State private var screen: AppScreen = .loading
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            switch screen {
            case .loading:
                LoadingView()
                    .task {
                        try? await Task.sleep(nanoseconds: 1_400_000_000)
                        withAnimation(.easeInOut(duration: 0.25)) {
                            screen = .consent
                        }
                    }
            case .consent:
                ConsentGateView(
                    errorMessage: errorMessage,
                    onStart: startPrank
                )
            case .capture:
                CameraCaptureView(
                    onCaptured: handleCapture,
                    onFailed: handleCaptureFailure
                )
            case .permissionDenied:
                PermissionDeniedView(onTryAgain: startPrank)
            case .reveal(let photo):
                RevealView(
                    photo: photo,
                    onDone: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            screen = .finished
                        }
                    }
                )
            case .finished:
                FinishedView(
                    onReset: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            screen = .consent
                        }
                    }
                )
            }
        }
    }

    private func startPrank() {
        Task {
            let granted = await camera.requestCameraAccess()
            await MainActor.run {
                errorMessage = nil
                withAnimation(.easeInOut(duration: 0.25)) {
                    screen = granted ? .capture : .permissionDenied
                }
            }
        }
    }

    private func handleCapture(_ result: PhotoCaptureResult) {
        do {
            let photo = try store.savePhoto(
                imageData: result.imageData,
                metadata: result.metadata
            )
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                screen = .reveal(photo)
            }
        } catch {
            errorMessage = error.localizedDescription
            withAnimation(.easeInOut(duration: 0.25)) {
                screen = .consent
            }
        }
    }

    private func handleCaptureFailure(_ error: Error) {
        errorMessage = error.localizedDescription
        withAnimation(.easeInOut(duration: 0.25)) {
            screen = .consent
        }
    }
}

