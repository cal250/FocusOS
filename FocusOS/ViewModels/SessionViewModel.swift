import SwiftUI
import Combine
import UserNotifications

class SessionViewModel: ObservableObject {
    @Published var currentSession: StudySession?
    @Published var isSessionActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var pastSessions: [StudySession] = []
    
    private var timer: Timer?
    @Published var elapsedTime: TimeInterval = 0
    @Published var showCongratulationAlert: Bool = false
    @Published var sessionCompleted: Bool = false // Tracks if the set time was reached
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        requestNotificationPermissions()
        loadInitialData()
        
        // Reload data when user changes
        SupabaseManager.shared.$currentUser
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadInitialData()
            }
            .store(in: &cancellables)
    }
    
    func loadInitialData() {
        print("SessionViewModel: loadInitialData triggered")
        Task {
            do {
                let sessions = try await SupabaseManager.shared.fetchSessions()
                await MainActor.run {
                    self.pastSessions = sessions
                    print("SessionViewModel: Loaded \(sessions.count) sessions")
                }
            } catch {
                print("SessionViewModel: Failed to load initial sessions - \(error.localizedDescription)")
            }
        }
    }
    
    var progress: Double {
        guard let duration = currentSession?.plannedDuration, duration > 0 else { return 0 }
        return min(elapsedTime / duration, 1.0)
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
    
    func scheduleNotification(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "Congratulations! You reached your goal."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "sessionComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func startSession(tag: String? = nil, duration: TimeInterval? = nil) {
        currentSession = StudySession(startTime: Date(), tag: tag, plannedDuration: duration)
        isSessionActive = true
        isPaused = false
        sessionCompleted = false
        elapsedTime = 0
        
        if let duration = duration {
            scheduleNotification(duration: duration)
        }
        
        HapticManager.shared.playImpact(style: .medium)
        startTimer()
    }
    
    func pauseSession() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        cancelNotifications()
    }
    
    func resumeSession() {
        isPaused = false
        
        if let duration = currentSession?.plannedDuration {
            let remaining = duration - elapsedTime
            if remaining > 0 {
                scheduleNotification(duration: remaining)
            }
        }
        
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            
            // Check for completion
            if let duration = self.currentSession?.plannedDuration, 
               self.elapsedTime >= duration, 
               !self.sessionCompleted {
                self.sessionCompleted = true
                self.showCongratulationAlert = true
                // We keep the timer running if they want to continue, or we could stop? 
                // Requirement implies notification. We'll let it run but show alert.
                // For a strict timer, we might stop. Let's send a notification sound/vibration here ideally.
            }
        }
    }
    
    func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        session.focusScore = InsightEngine.calculateFocusScore(duration: session.duration, distractionCount: session.distractions.count)
        
        pastSessions.append(session)
        syncSession(session)
        syncDailyStats(with: session)
        
        currentSession = nil
        isSessionActive = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        
        cancelNotifications()
        
        // Show congrats if we stopped manually (and haven't already shown it for completion)
        // Or essentially always show it on stop as "Congratulions and encouragement" requested.
        showCongratulationAlert = true
        HapticManager.shared.playNotification(type: .success)
    }
    
    private func syncSession(_ session: StudySession) {
        Task {
            do {
                try await SupabaseManager.shared.saveSession(session)
                print("SessionViewModel: Successfully synced individual session \(session.id)")
            } catch {
                print("SessionViewModel: Failed to sync individual session - \(error.localizedDescription)")
            }
        }
    }
    
    private func syncDailyStats(with session: StudySession) {
        Task {
            do {
                let manager = SupabaseManager.shared
                guard let userId = manager.currentUser?.id else {
                    print("SessionViewModel: No user logged in, skipping stats sync")
                    return
                }
                
                // 1. Fetch current stats for today
                let today = Date()
                var currentStat = try await manager.fetchDailyStats(for: today) ?? DailyStat(
                    userId: userId,
                    date: formatDate(today),
                    totalFocusTime: 0,
                    sessionCount: 0,
                    avgProductivityScore: 0,
                    distractionCount: 0
                )
                
                // 2. Update stats
                let sessionDuration = Int(session.duration)
                let sessionScore = session.focusScore
                let sessionDistractions = session.distractions.count
                
                let oldTotalScore = currentStat.avgProductivityScore * Double(currentStat.sessionCount)
                currentStat.sessionCount += 1
                currentStat.totalFocusTime += sessionDuration
                currentStat.distractionCount += sessionDistractions
                currentStat.avgProductivityScore = (oldTotalScore + sessionScore) / Double(currentStat.sessionCount)
                
                // 3. Upsert
                try await manager.upsertDailyStat(currentStat)
                print("SessionViewModel: Successfully synced daily stats for \(currentStat.date)")
            } catch {
                print("SessionViewModel: Failed to sync stats - \(error.localizedDescription)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func logDistraction(description: String) {
        guard var session = currentSession else { return }
        let distraction = Distraction(description: description)
        session.distractions.append(distraction)
        currentSession = session
        HapticManager.shared.playImpact(style: .light)
    }
    
    func formattedElapsedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
