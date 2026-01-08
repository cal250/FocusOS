import Foundation

struct DailyStat: Identifiable, Codable {
    var id: UUID?
    let userId: UUID
    let date: String // ISO8601 date string YYYY-MM-DD
    var totalFocusTime: Int // in seconds
    var sessionCount: Int
    var avgProductivityScore: Double
    var distractionCount: Int
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case totalFocusTime = "total_focus_time"
        case sessionCount = "session_count"
        case avgProductivityScore = "avg_productivity_score"
        case distractionCount = "distraction_count"
        case updatedAt = "updated_at"
    }
}
