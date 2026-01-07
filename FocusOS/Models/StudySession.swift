import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var focusScore: Double
    var distractions: [Distraction]
    var tag: String?
    var plannedDuration: TimeInterval?
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, focusScore: Double = 100.0, distractions: [Distraction] = [], tag: String? = nil, plannedDuration: TimeInterval? = nil) {
        self.id = id
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
