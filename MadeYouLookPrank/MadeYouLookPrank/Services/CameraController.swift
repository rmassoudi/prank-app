import AVFoundation
import Foundation

enum CameraAccessState: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted

    static var current: CameraAccessState {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}

enum CameraControllerError: LocalizedError {
    case accessDenied
    case noFrontCamera
    case cannotAddInput
    case cannotAddOutput
    case captureAlreadyInProgress
    case missingImageData

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Camera access is not available. Enable camera access in Settings to run the prank."
        case .noFrontCamera:
            return "This device does not have an available front camera."
        case .cannotAddInput:
            return "The front camera could not be attached to the capture session."
        case .cannotAddOutput:
            return "The photo output could not be attached to the capture session."
        case .captureAlreadyInProgress:
            return "A capture is already in progress."
        case .missingImageData:
            return "The camera did not return image data."
        }
    }
}

struct PhotoCaptureResult {
    let imageData: Data
    let metadata: [String: String]
}

final class CameraController: NSObject, ObservableObject {
    @Published private(set) var accessState: CameraAccessState = .current

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.madeyoulook.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var isConfigured = false
    private var activeDelegate: PhotoCaptureDelegate?

    @MainActor
    func refreshAccessState() {
        accessState = .current
    }

    @MainActor
    func requestCameraAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            accessState = .authorized
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            accessState = granted ? .authorized : .denied
            return granted
        case .denied:
            accessState = .denied
            return false
        case .restricted:
            accessState = .restricted
            return false
        @unknown default:
            accessState = .denied
            return false
        }
    }

    func configureIfNeeded() async throws {
        try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                do {
                    try self.configureSessionIfNeeded()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func startSession() {
        sessionQueue.async {
            guard self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func captureFrontPhoto() async throws -> PhotoCaptureResult {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw CameraControllerError.accessDenied
        }

        try await configureIfNeeded()

        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                guard self.activeDelegate == nil else {
                    continuation.resume(throwing: CameraControllerError.captureAlreadyInProgress)
                    return
                }

                let settings = AVCapturePhotoSettings()
                if self.photoOutput.supportedFlashModes.contains(.off) {
                    settings.flashMode = .off
                }
                settings.photoQualityPrioritization = .balanced

                if let connection = self.photoOutput.connection(with: .video),
                   connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }

                let delegate = PhotoCaptureDelegate(continuation: continuation) { [weak self] in
                    self?.sessionQueue.async {
                        self?.activeDelegate = nil
                    }
                }

                self.activeDelegate = delegate
                self.photoOutput.capturePhoto(with: settings, delegate: delegate)
            }
        }
    }

    private func configureSessionIfNeeded() throws {
        guard !isConfigured else { return }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw CameraControllerError.accessDenied
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            throw CameraControllerError.noFrontCamera
        }

        let input = try AVCaptureDeviceInput(device: camera)
        guard session.canAddInput(input) else {
            throw CameraControllerError.cannotAddInput
        }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else {
            throw CameraControllerError.cannotAddOutput
        }
        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .balanced

        isConfigured = true
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let continuation: CheckedContinuation<PhotoCaptureResult, Error>
    private let cleanup: () -> Void
    private var didResume = false

    init(
        continuation: CheckedContinuation<PhotoCaptureResult, Error>,
        cleanup: @escaping () -> Void
    ) {
        self.continuation = continuation
        self.cleanup = cleanup
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard !didResume else { return }
        didResume = true
        defer { cleanup() }

        if let error {
            continuation.resume(throwing: error)
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            continuation.resume(throwing: CameraControllerError.missingImageData)
            return
        }

        continuation.resume(
            returning: PhotoCaptureResult(
                imageData: imageData,
                metadata: Self.stringMetadata(from: photo.metadata)
            )
        )
    }

    private static func stringMetadata(from metadata: [String: Any]) -> [String: String] {
        var output: [String: String] = [:]

        func append(_ value: Any, key: String) {
            switch value {
            case let string as String:
                output[key] = string
            case let number as NSNumber:
                output[key] = number.stringValue
            case let date as Date:
                output[key] = ISO8601DateFormatter().string(from: date)
            default:
                break
            }
        }

        for (key, value) in metadata {
            if let nested = value as? [String: Any] {
                for (nestedKey, nestedValue) in nested {
                    append(nestedValue, key: "\(key).\(nestedKey)")
                }
            } else {
                append(value, key: key)
            }
        }

        return output
    }
}

