import XCTest
@testable import MadeYouLookPrank

@MainActor
final class CaptureStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CaptureStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory,
           FileManager.default.fileExists(atPath: tempDirectory.path) {
            try FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
    }

    func testSavePhotoPersistsFileAndManifestMetadata() throws {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let store = CaptureStore(rootURL: tempDirectory, dateProvider: { fixedDate })

        let photo = try store.savePhoto(
            imageData: sampleJPEGData,
            metadata: ["camera": "front"]
        )

        XCTAssertEqual(store.photos.count, 1)
        XCTAssertEqual(store.photos.first?.id, photo.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.photoURL(for: photo).path))
        XCTAssertEqual(photo.metadata["camera"], "front")
        XCTAssertEqual(photo.metadata["storage"], "local-application-support")
        XCTAssertNotNil(photo.metadata["capturedAt"])

        let reloadedStore = CaptureStore(rootURL: tempDirectory)
        XCTAssertEqual(reloadedStore.photos, [photo])
    }

    func testDeleteRemovesFileAndManifestEntry() throws {
        let store = CaptureStore(rootURL: tempDirectory)
        let photo = try store.savePhoto(imageData: sampleJPEGData, metadata: [:])

        try store.delete(photo)

        XCTAssertTrue(store.photos.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.photoURL(for: photo).path))

        let reloadedStore = CaptureStore(rootURL: tempDirectory)
        XCTAssertTrue(reloadedStore.photos.isEmpty)
    }

    func testClearAllRemovesEveryPhoto() throws {
        let store = CaptureStore(rootURL: tempDirectory)
        _ = try store.savePhoto(imageData: sampleJPEGData, metadata: ["index": "1"])
        _ = try store.savePhoto(imageData: sampleJPEGData, metadata: ["index": "2"])

        XCTAssertEqual(store.photos.count, 2)

        try store.clearAll()

        XCTAssertTrue(store.photos.isEmpty)
        let remainingFiles = try FileManager.default.contentsOfDirectory(
            at: tempDirectory,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(remainingFiles.map(\.lastPathComponent), ["manifest.json"])
    }

    private var sampleJPEGData: Data {
        Data([0xFF, 0xD8, 0xFF, 0xD9])
    }
}

