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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    // Hide default tab bar
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        let isIPad = horizontalSizeClass == .regular
        
        Group {
            if isIPad {
                // iPad: NavigationSplitView with persistent sidebar
                NavigationSplitView {
                    iPadSidebarView(selectedTab: $selectedTab)
                } detail: {
                    contentView(for: selectedTab)
                        .overlay(
                            WalkthroughOverlay(activeTab: $selectedTab, anchorFrames: anchorFrames)
                                .edgesIgnoringSafeArea(.all)
                        )
                        .onPreferenceChange(WalkthroughAnchorKey.self) { preferences in
                            self.anchorFrames = preferences
                        }
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                // iPhone: Existing TabView + CustomTabBar (unchanged)
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
                    
                    // Custom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
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
    }
    
    // MARK: - Content View Helper
    
    @ViewBuilder
    private func contentView(for tab: Tab) -> some View {
        switch tab {
        case .today:
            TodayView(activeTab: $selectedTab)
        case .habits:
            HabitsView()
        case .focus:
            HomeView()
        case .settings:
            SettingsView()
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
                    .walkthroughAnchor(anchor(for: tab))
                    
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 30) // Extra padding for safe area
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func anchor(for tab: Tab) -> WalkthroughStep {
        switch tab {
        case .today: return .navToday
        case .habits: return .navHabits
        case .focus: return .navFocus
        case .settings: return .navSettings
        }
    }
}
