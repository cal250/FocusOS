import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    var userId: UUID? // Optional locally, required for DB
    let startTime: Date
    var endTime: Date?
    var focusScore: Double
    var distractions: [Distraction]
    var tag: String?
    var plannedDuration: TimeInterval?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case focusScore = "focus_score"
        case distractions
        case tag
        case plannedDuration = "planned_duration"
    }
    
    init(id: UUID = UUID(), userId: UUID? = nil, startTime: Date = Date(), endTime: Date? = nil, focusScore: Double = 100.0, distractions: [Distraction] = [], tag: String? = nil, plannedDuration: TimeInterval? = nil) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.focusScore = focusScore
        self.distractions = distractions
        self.tag = tag
        self.plannedDuration = plannedDuration
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
}
