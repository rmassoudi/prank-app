import Foundation
import Photos

enum PhotoLibraryExportError: LocalizedError {
    case notAuthorized
    case noPhotos
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Photos access was not granted, so the export could not be completed."
        case .noPhotos:
            return "There are no photos to export."
        case .exportFailed:
            return "The photos could not be saved to the Photos library."
        }
    }
}

struct PhotoLibraryExporter {
    static func export(photoURLs: [URL]) async throws {
        guard !photoURLs.isEmpty else {
            throw PhotoLibraryExportError.noPhotos
        }

        let authorized = await requestAddOnlyAuthorizationIfNeeded()
        guard authorized else {
            throw PhotoLibraryExportError.notAuthorized
        }

        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                for url in photoURLs {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, fileURL: url, options: nil)
                }
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: PhotoLibraryExportError.exportFailed)
                }
            }
        }
    }

    private static func requestAddOnlyAuthorizationIfNeeded() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return status == .authorized || status == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}

