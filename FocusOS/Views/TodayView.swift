import SwiftUI

struct TodayView: View {
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @Binding var activeTab: Tab
    @EnvironmentObject var viewModel: SessionViewModel
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    // Real Data Logic
    private var calendar: Calendar { Calendar.current }
    private var today: Date { Date() }
    
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @Namespace private var animationNamespace
    @State private var showingHistory = false
    
    // Supabase Stats State
    @State private var dailyStat: DailyStat?
    @State private var isLoadingStats = false
    
    private var currentDay: Int {
        calendar.component(.day, from: today)
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: today)?.count ?? 30
    }
    
    private var startOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: firstOfMonth) - 1
    }
    
    // Data Helpers
    func fetchStats() {
        let selectedDateComponents = DateComponents(year: calendar.component(.year, from: today),
                                                    month: calendar.component(.month, from: today),
                                                    day: selectedDay)
        guard let date = calendar.date(from: selectedDateComponents) else { return }
        
        isLoadingStats = true
        Task {
            do {
                let stat = try await SupabaseManager.shared.fetchDailyStats(for: date)
                await MainActor.run {
                    self.dailyStat = stat
                    self.isLoadingStats = false
                }
            } catch {
                print("TodayView: Failed to fetch stats - \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoadingStats = false
                }
            }
        }
    }

    var distractionInfoForSelectedDay: (distractions: Int, sessions: Int) {
        if let stat = dailyStat {
            return (stat.distractionCount, stat.sessionCount)
        }
        return (0, 0)
    }
    
    var displayStats: (time: String, sessions: String, score: String) {
        if let stat = dailyStat {
            let hours = stat.totalFocusTime / 3600
            let minutes = (stat.totalFocusTime / 60) % 60
            let timeString = String(format: "%dh %02dm", hours, minutes)
            return (timeString, "\(stat.sessionCount)", "\(Int(stat.avgProductivityScore))%")
        } else {
            return ("0h 00m", "0", "0%")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    headerView
                    calendarView
                    distractionIndicatorView
                    summaryCardsView
                    productivityCardView
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .onAppear {
                fetchStats()
            }
            .onChange(of: selectedDay) {
                fetchStats()
            }
            .onChange(of: supabaseManager.currentUser) {
                fetchStats()
            }
            .onChange(of: viewModel.pastSessions.count) {
                fetchStats()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Subviews
extension TodayView {
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Spacer()
            
            NavigationLink(destination: AccountView()) {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .walkthroughAnchor(.accountIcon)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var calendarView: some View {
        VStack(spacing: 15) {
            // Weekday Headers
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                // Offset for start of month
                ForEach(0..<startOffset, id: \.self) { _ in Spacer() }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    let isFuture = day > currentDay
                    let isToday = day == currentDay
                    let isSelected = selectedDay == day
                    
                    VStack(spacing: 4) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Color.blue)
                                    .matchedGeometryEffect(id: "selection", in: animationNamespace)
                            }
                            
                            Text("\(day)")
                                .font(.system(size: 14, weight: isToday || isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : (isToday ? .blue : (isFuture ? .gray.opacity(0.3) : .primary)))
                        }
                        .frame(width: 30, height: 30)
                        
                        // Dot
                        Circle()
                            .fill(!isFuture && day % 2 != 0 ? Color.blue.opacity(0.5) : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                    .contentShape(Rectangle()) // Make touch area usable
                    .onTapGesture {
                        if !isFuture {
                            withAnimation(.spring()) {
                                selectedDay = day
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .walkthroughAnchor(.calendar) // Attached to calendar card
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var distractionIndicatorView: some View {
        VStack(spacing: 8) {
            let info = distractionInfoForSelectedDay
            
            HStack(spacing: 8) {
                if info.sessions > 0 && info.distractions == 0 {
                    // Perfect Day
                     Circle()
                         .fill(Color.blue)
                         .frame(width: 8, height: 8)
                } else {
                    // Mixed or Empty
                    let count = info.distractions
                    let maxDots = 8
                    
                    let displayCount = min(count, maxDots)
                    
                    ForEach(0..<maxDots, id: \.self) { index in
                        if index < displayCount {
                            Circle()
                                .fill(Color.orange.opacity(0.7))
                                .frame(width: 8, height: 8)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if count > maxDots {
                        Text("+\(count - maxDots)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if info.sessions > 0 && info.distractions == 0 {
                 Text("Perfect focus today!")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else if info.sessions == 0 {
                Text("No sessions recorded")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Distractions logged today")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 5)
        .onTapGesture {
            activeTab = .habits
        }
    }
    
    @ViewBuilder
    private var summaryCardsView: some View {
        let stats = displayStats
        HStack(spacing: 15) {
            SummaryCard(
                title: "Focus Time",
                value: stats.time,
                icon: "timer",
                color: .blue
            )
            .walkthroughAnchor(.focusTimeCard)
            
            NavigationLink(destination: SessionHistoryView()) {
                SummaryCard(
                    title: "Sessions",
                    value: stats.sessions,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            .buttonStyle(PlainButtonStyle())
            .walkthroughAnchor(.sessionsCard)
        }
        .padding(.horizontal)
        .overlay(
            Group {
                if isLoadingStats {
                    ProgressView()
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        )
    }

    @ViewBuilder
    private var productivityCardView: some View {
        let stats = displayStats
        SummaryCard(
            title: "Productivity Score",
            value: stats.score,
            icon: "chart.bar.fill",
            color: .orange
        )
        .walkthroughAnchor(.productivityCard)
        .padding(.horizontal)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
