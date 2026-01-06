import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var focusScore: Double
    var distractions: [Distraction]
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, focusScore: Double = 100.0, distractions: [Distraction] = []) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.focusScore = focusScore
        self.distractions = distractions
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
}
