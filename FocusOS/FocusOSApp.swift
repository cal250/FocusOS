import SwiftUI

enum AppPhase {
    case splash
    case auth
    case onboarding
    case main
}

@main
struct FocusOSApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var appPhase: AppPhase = .splash
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appPhase {
                case .splash:
                    SplashScreenView {
                        withAnimation {
                            appPhase = .auth
                        }
                    }
                case .auth:
                    AuthView {
                        withAnimation {
                            appPhase = .onboarding
                        }
                    }
                    .transition(.opacity)
                case .onboarding:
                    OnboardingView {
                        withAnimation {
                            appPhase = .main
                        }
                    }
                    .transition(.opacity)
                case .main:
                    MainTabView()
                        .environmentObject(sessionViewModel)
                        .transition(.opacity)
                }
            }
        }
    }
}
