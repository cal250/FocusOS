import SwiftUI
import Combine

class SessionViewModel: ObservableObject {
    @Published var currentSession: StudySession?
    @Published var isSessionActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var pastSessions: [StudySession] = []
    
    private var timer: Timer?
    @Published var elapsedTime: TimeInterval = 0
    
    func startSession() {
        currentSession = StudySession()
        isSessionActive = true
        isPaused = false
        elapsedTime = 0
        startTimer()
    }
    
    func pauseSession() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resumeSession() {
        isPaused = false
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }
    
    func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        session.focusScore = InsightEngine.calculateFocusScore(duration: session.duration, distractionCount: session.distractions.count)
        
        pastSessions.append(session)
        currentSession = nil
        isSessionActive = false
        isPaused = false
        timer?.invalidate()
        timer = nil
    }
    
    func logDistraction(description: String) {
        guard var session = currentSession else { return }
        let distraction = Distraction(description: description)
        session.distractions.append(distraction)
        currentSession = session
    }
    
    func formattedElapsedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
