import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        print("NotificationManager: Requesting authorization...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("NotificationManager: Authorization error: \(error.localizedDescription)")
                } else {
                    print("NotificationManager: Authorization granted: \(granted)")
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("NotificationManager: Current Authorization Status: \(settings.authorizationStatus.rawValue)")
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Scheduling
    
    func scheduleSessionEndNotification(timeRemaining: TimeInterval) {
        print("NotificationManager: Attempting to schedule notification for \(timeRemaining) seconds...")
        
        // Remove any pending notifications first to avoid duplicates
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete"
        content.body = "Great job! Your focus session has ended. Take a break."
        content.sound = .default
        
        // Trigger after the remaining time
        // Ensure time is positive
        guard timeRemaining > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        
        let request = UNNotificationRequest(identifier: "session_end_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationManager: Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("NotificationManager: Notification scheduled for \(Int(timeRemaining)) seconds from now.")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("NotificationManager: All pending notifications cancelled.")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the banner and play sound even if app is open
        completionHandler([.banner, .sound])
    }
}
