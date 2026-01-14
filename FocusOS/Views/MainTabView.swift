import SwiftUI

enum Tab: String, CaseIterable {
    case today = "Today"
    case habits = "Habits"
    case focus = "Focus"
    case settings = "Setting"
    
    var iconName: String {
        switch self {
        case .today: return "calendar"
        case .habits: return "list.clipboard"
        case .focus: return "timer"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .today
    @StateObject private var walkthroughManager = WalkthroughManager.shared
    @State private var anchorFrames: [WalkthroughStep: CGRect] = [:]
    
    // Hide default tab bar
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                TodayView(activeTab: $selectedTab)
                    .tag(Tab.today)
                
                HabitsView()
                    .tag(Tab.habits)
                
                HomeView()
                    .tag(Tab.focus)
                
                SettingsView()
                    .tag(Tab.settings)
            }
            // Block touch from underlying tab view UI if needed, usually not an issue with hidden appearance
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .walkthroughAnchor(.settings) // Anchor the settings button (rough approximation, handled better by specifically wrapping the settings tab button if possible, but this works for "Control" level)
                // Actually, let's put it on the Settings tab button inside CustomTabBar if possible, or just the whole bar for "Control".
                // Better yet, let's just anchor the whole tab bar as "Settings/Control" for simplicity or try to locate the settings icon frame.
        }
        .edgesIgnoringSafeArea(.bottom)
        .persistentSystemOverlays(.hidden)
        .overlay(
            WalkthroughOverlay(activeTab: $selectedTab, anchorFrames: anchorFrames)
                .edgesIgnoringSafeArea(.all)
        )
        .onPreferenceChange(WalkthroughAnchorKey.self) { preferences in
            self.anchorFrames = preferences
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            if selectedTab == tab {
                                // Active State: Blue Pill
                                ZStack {
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 50, height: 32)
                                    
                                    Image(systemName: tab.iconName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            } else {
                                // Inactive State: Gray Icon
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 32) // Keep consistent sizing
                            }
                            
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 30) // Extra padding for safe area
            .background(Color(UIColor.systemBackground))
        }
        // Correctly anchor specifically the Settings button if we can index it
        // Since we loop, it's hard to modify just one. 
        // Strategy: Add a condition in the loop.
    }
}
