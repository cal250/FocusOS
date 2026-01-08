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
    @StateObject private var habitsViewModel = HabitsViewModel()
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var appPhase: AppPhase = .splash
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appPhase {
                case .splash:
                    SplashScreenView {
                        withAnimation {
                            if supabaseManager.session != nil {
                                appPhase = .main
                            } else {
                                appPhase = .auth
                            }
                        }
                    }
                case .auth:
                    AuthView { isSignUp in
                        withAnimation {
                            if isSignUp {
                                appPhase = .onboarding
                            } else {
                                appPhase = .main
                            }
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
                        .environmentObject(habitsViewModel)
                        .transition(.opacity)
                }
            }
            .onChange(of: supabaseManager.session) { _, newSession in
                withAnimation {
                    if newSession == nil {
                        appPhase = .auth
                    } else if appPhase == .auth {
                        appPhase = .onboarding
                    }
                }
            }
        }
    }
}
