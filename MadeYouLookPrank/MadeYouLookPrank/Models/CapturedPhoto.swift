import Foundation

struct CapturedPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let filename: String
    let createdAt: Date
    let metadata: [String: String]

    var displayTimestamp: String {
        createdAt.formatted(date: .abbreviated, time: .standard)
    }

    static let fileTimestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}

