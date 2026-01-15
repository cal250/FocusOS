import SwiftUI
import Combine

enum WalkthroughStep: Int, CaseIterable, Codable {
    // Dashboard (TodayView)
    case calendar = 0
    case focusTimeCard = 1
    case sessionsCard = 2
    case productivityCard = 3
    
    // Navigation (TabBar)
    case navToday = 4
    case navHabits = 5
    case navFocus = 6
    case navSettings = 7
    
    // Feature Highlights (Navigate to them)
    case startFocus = 8
    case habitsSection = 9
    
    case completed = 99
    
    var title: String {
        switch self {
        case .calendar: return "Your Schedule"
        case .focusTimeCard: return "Focus Time"
        case .sessionsCard: return "Total Sessions"
        case .productivityCard: return "Productivity Score"
        
        case .navToday: return "Today Tab"
        case .navHabits: return "Habits Tab"
        case .navFocus: return "Focus Timer"
        case .navSettings: return "Settings"
            
        case .startFocus: return "Start Focusing"
        case .habitsSection: return "Track Habits"
        default: return ""
        }
    }
    
    var description: String {
        switch self {
        case .calendar: return "Track your consistency and view daily records here."
        case .focusTimeCard: return "See how many minutes you've focused today."
        case .sessionsCard: return "Count your completed sessions. Tap to see history."
        case .productivityCard: return "Measure your focus quality and efficiency."
            
        case .navToday: return "Return to your daily overview anytime."
        case .navHabits: return "Manage habits and view distraction logs."
        case .navFocus: return "The core timer to start your deep work sessions."
        case .navSettings: return "Customize your preferences and account."
            
        case .startFocus: return "Tap this button to begin a new focus session."
        case .habitsSection: return "Log habits you want to break or build."
        default: return ""
        }
    }
    
    var requiredTab: Tab? {
        switch self {
        case .calendar, .focusTimeCard, .sessionsCard, .productivityCard, .navToday: 
            return .today
        case .navHabits, .habitsSection: 
            return .habits
        case .navFocus, .startFocus: 
            return .focus
        case .navSettings:
            return .settings
        default: return nil
        }
    }
    
    enum ShapeType {
        case roundedRect(cornerRadius: CGFloat)
        case circle
    }
    
    var shape: ShapeType {
        switch self {
        case .startFocus:
            return .circle
        default:
            return .roundedRect(cornerRadius: 15)
        }
    }
}

class WalkthroughManager: ObservableObject {
    @AppStorage("hasSeenWalkthrough") var hasSeenWalkthrough: Bool = false
    @Published var currentStep: WalkthroughStep = .calendar
    @Published var isActive: Bool = false
    
    static let shared = WalkthroughManager()
    
    private init() {
        // Automatically start if not seen
        if !hasSeenWalkthrough {
            start()
        }
    }
    
    func start() {
        currentStep = .calendar
        isActive = true
    }
    
    func next() {
        // Logic to move to next step or complete
        let allSteps = WalkthroughStep.allCases.sorted(by: { $0.rawValue < $1.rawValue })
        if let currentIndex = allSteps.firstIndex(of: currentStep), currentIndex + 1 < allSteps.count {
            let nextStep = allSteps[currentIndex + 1]
            if nextStep == .completed {
                complete()
            } else {
                withAnimation {
                    currentStep = nextStep
                }
            }
        } else {
            complete()
        }
    }
    
    func skip() {
        complete()
    }
    
    func reset() {
        hasSeenWalkthrough = false
        start()
    }
    
    private func complete() {
        withAnimation {
            isActive = false
            hasSeenWalkthrough = true
        }
    }
}
