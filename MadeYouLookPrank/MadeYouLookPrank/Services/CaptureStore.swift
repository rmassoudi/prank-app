import Foundation

@MainActor
final class CaptureStore: ObservableObject {
    @Published private(set) var photos: [CapturedPhoto] = []
    @Published var lastErrorMessage: String?

    private let fileManager: FileManager
    private let rootURL: URL
    private let manifestURL: URL
    private let dateProvider: () -> Date

    init(
        fileManager: FileManager = .default,
        rootURL: URL? = nil,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.fileManager = fileManager
        self.dateProvider = dateProvider

        let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory

        let resolvedRootURL = rootURL ?? applicationSupport
            .appendingPathComponent("MadeYouLookPrank", isDirectory: true)
            .appendingPathComponent("Captures", isDirectory: true)

        self.rootURL = resolvedRootURL
        self.manifestURL = resolvedRootURL.appendingPathComponent("manifest.json")

        reload()
    }

    func photoURL(for photo: CapturedPhoto) -> URL {
        rootURL.appendingPathComponent(photo.filename)
    }

    @discardableResult
    func savePhoto(imageData: Data, metadata: [String: String]) throws -> CapturedPhoto {
        try ensureStorageExists()

        let now = dateProvider()
        let id = UUID()
        let filename = "\(CapturedPhoto.fileTimestampFormatter.string(from: now))_\(id.uuidString).jpg"
        let destinationURL = rootURL.appendingPathComponent(filename)

        var manifestMetadata = metadata
        manifestMetadata["capturedAt"] = ISO8601DateFormatter().string(from: now)
        manifestMetadata["storage"] = "local-application-support"

        let record = CapturedPhoto(
            id: id,
            filename: filename,
            createdAt: now,
            metadata: manifestMetadata
        )

        try imageData.write(to: destinationURL, options: [.atomic])

        var manifest = try readManifest()
        manifest.append(record)
        try writeManifest(manifest)
        photos = sortedExistingPhotos(from: manifest)
        return record
    }

    func reload() {
        do {
            try ensureStorageExists()
            photos = sortedExistingPhotos(from: try readManifest())
            lastErrorMessage = nil
        } catch {
            photos = []
            lastErrorMessage = error.localizedDescription
        }
    }

    func delete(_ photo: CapturedPhoto) throws {
        let url = photoURL(for: photo)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        let manifest = try readManifest().filter { $0.id != photo.id }
        try writeManifest(manifest)
        photos = sortedExistingPhotos(from: manifest)
    }

    func clearAll() throws {
        let manifest = try readManifest()
        for photo in manifest {
            let url = photoURL(for: photo)
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        }
        try writeManifest([])
        photos = []
    }

    func allPhotoURLs() -> [URL] {
        photos.map(photoURL(for:))
    }

    private func ensureStorageExists() throws {
        try fileManager.createDirectory(
            at: rootURL,
            withIntermediateDirectories: true
        )
    }

    private func readManifest() throws -> [CapturedPhoto] {
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            return []
        }

        let data = try Data(contentsOf: manifestURL)
        return try JSONDecoder.captureManifest.decode([CapturedPhoto].self, from: data)
    }

    private func writeManifest(_ photos: [CapturedPhoto]) throws {
        let data = try JSONEncoder.captureManifest.encode(photos)
        try data.write(to: manifestURL, options: [.atomic])
    }

    private func sortedExistingPhotos(from manifest: [CapturedPhoto]) -> [CapturedPhoto] {
        manifest
            .filter { fileManager.fileExists(atPath: photoURL(for: $0).path) }
            .sorted { $0.createdAt > $1.createdAt }
    }
}

private extension JSONEncoder {
    static var captureManifest: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var captureManifest: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

