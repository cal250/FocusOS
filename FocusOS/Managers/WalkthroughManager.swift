import SwiftUI
import Combine

enum WalkthroughStep: Int, CaseIterable, Codable {
    case todayOverview = 0
    case sessionHistory = 1
    case startFocus = 2
    case habitsSection = 3
    case settings = 4
    case completed = 99
    
    var title: String {
        switch self {
        case .todayOverview: return "Daily Overview"
        case .sessionHistory: return "Your Progress"
        case .startFocus: return "Start Focusing"
        case .habitsSection: return "Mindful Habits"
        case .settings: return "Your Control"
        default: return ""
        }
    }
    
    var description: String {
        switch self {
        case .todayOverview: return "See your daily focus stats at a glance here."
        case .sessionHistory: return "Reflect on your past sessions and patterns."
        case .startFocus: return "Tap here to begin an intentional focus session."
        case .habitsSection: return "Track habits and distractions without judgment."
        case .settings: return "Customize your experience and preferences."
        default: return ""
        }
    }
    
    var requiredTab: Tab? {
        switch self {
        case .todayOverview, .sessionHistory: return .today
        case .startFocus: return .focus
        case .habitsSection: return .habits
        case .settings: return nil // Special case, usually points to the tab bar item itself
        default: return nil
        }
    }
}

class WalkthroughManager: ObservableObject {
    @AppStorage("hasSeenWalkthrough") var hasSeenWalkthrough: Bool = false
    @Published var currentStep: WalkthroughStep = .todayOverview
    @Published var isActive: Bool = false
    
    static let shared = WalkthroughManager()
    
    private init() {
        // Automatically start if not seen
        if !hasSeenWalkthrough {
            start()
        }
    }
    
    func start() {
        currentStep = .todayOverview
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
