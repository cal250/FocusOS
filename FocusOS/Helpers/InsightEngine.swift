import Foundation

struct InsightEngine {
    static func calculateFocusScore(duration: TimeInterval, distractionCount: Int) -> Double {
        // Simple algorithm: Start with 100, deduct points for distractions based on frequency per hour
        // This is a placeholder logic
        let hours = duration / 3600.0
        let penaltyPerDistraction = 5.0
        let baseScore = 100.0
        
        // Avoid division by zero if duration is very small
        let effectiveHours = max(hours, 0.1)
        
        let distractionRate = Double(distractionCount) / effectiveHours
        let penalty = distractionRate * penaltyPerDistraction
        
        return max(0, baseScore - penalty)
    }
    
    static func generateSummary(for session: StudySession) -> String {
        return "You stayed focused for \(Int(session.duration / 60)) minutes with \(session.distractions.count) distractions."
    }
}
