import SwiftUI
import Supabase

struct iPadSidebarView: View {
    @Binding var selectedTab: Tab
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var supabaseManager = SupabaseManager.shared
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    // Stats for the footer
    @State private var todaysStats: DailyStat?
    
    // Sheet State
    @State private var showingAccountSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. User Profile Profile (Top)
            Button(action: {
                showingAccountSheet = true
            }) {
                UserProfileSidebarHeader(user: supabaseManager.currentUser)
                    .contentShape(Rectangle()) // Make entire area tappable
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .sheet(isPresented: $showingAccountSheet) {
                 NavigationView {
                     AccountView()
                         .navigationBarItems(trailing: Button("Done") {
                             showingAccountSheet = false
                         })
                 }
            }
            
            // 2. Quick Actions
            VStack(spacing: 8) {
                QuickActionButton(
                    title: "Start Focus",
                    icon: "play.fill",
                    color: .blue
                ) {
                    selectedTab = .focus
                }
                
                QuickActionButton(
                    title: "New Habit",
                    icon: "plus",
                    color: .green
                ) {
                    selectedTab = .habits
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            
            Divider()
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            
            // 3. Navigation
            VStack(spacing: 8) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    SidebarNavigationItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                                HapticManager.shared.playImpact(style: .light)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // 4. Logout Button (New)
            Button(action: {
                Task {
                    try? await SupabaseManager.shared.signOut()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.8))
                        .frame(width: 24)
                    
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // 5. Daily Stats Summary (Bottom)
            if let stats = todaysStats {
                DailyStatsSidebarFooter(stats: stats)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            } else {
                 // Fallback or Loading
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Focus")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Ready to start?")
                         .font(.caption)
                         .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .frame(width: 280)
        .grassySurface(cornerRadius: 0, material: .ultraThinMaterial)
        .onAppear {
            fetchStats()
        }
        // Refresh when session ends
        .onChange(of: sessionViewModel.pastSessions.count) {
             fetchStats()
        }
    }
    
    func fetchStats() {
        Task {
            do {
                if let stats = try await SupabaseManager.shared.fetchDailyStats(for: Date()) {
                    await MainActor.run {
                        self.todaysStats = stats
                    }
                }
            } catch {
                print("Sidebar: Failed to fetch stats")
            }
        }
    }
}

// MARK: - Components

struct UserProfileSidebarHeader: View {
    let user: User?
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar Placeholder
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(initials)
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user?.email ?? "Guest")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("FocusOS Pro") // Placeholder for tier
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    var initials: String {
        guard let email = user?.email else { return "G" }
        return String(email.prefix(2)).uppercased()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(10)
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DailyStatsSidebarFooter: View {
    let stats: DailyStat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Progress")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(formatTime(stats.totalFocusTime))
                        .font(.headline)
                    Text("\(stats.sessionCount) sessions")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Mini Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: min(Double(stats.totalFocusTime) / 3600.0, 1.0)) // Assume 1 hour goal for visual
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 32, height: 32)
            }
            .padding(12)
            .background(Color.white.opacity(0.5)) // Semi-transparent card
            .cornerRadius(12)
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }
}

// MARK: - Sidebar Navigation Item

struct SidebarNavigationItem: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .frame(width: 24)
                
                Text(tab.rawValue)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .walkthroughAnchor(anchor(for: tab))
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

struct iPadSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        iPadSidebarView(selectedTab: .constant(.today))
            .previewLayout(.sizeThatFits)
    }
}
