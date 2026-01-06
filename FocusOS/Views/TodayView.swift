import SwiftUI

struct TodayView: View {
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    // Mocking current month state
    let distinctMonthDays = 30
    let currentDay = 15 // Today is the 15th
    
    @State private var selectedDay = 15
    @Namespace private var animationNamespace
    
    // Mock Data generator
    func getStats(for day: Int) -> (time: String, sessions: String, score: String) {
        if day > currentDay { return ("-", "-", "-") }
        if day == 4 || day == 10 { return ("0h 00m", "0", "-") } // Random rest days
        
        // Random-ish data based on day
        let h = (day * 3) % 5
        let m = (day * 10) % 60
        return ("\(h)h \(m)m", "\(h+1)", "\(80 + (day % 15))%")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
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
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Month Calendar
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
                        // Offset for start of month (mocking starts on Tue for example)
                        ForEach(0..<2) { _ in Spacer() }
                        
                        ForEach(1...distinctMonthDays, id: \.self) { day in
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
                .padding(.horizontal)
                
                // Summary Cards
                let stats = getStats(for: selectedDay)
                
                HStack(spacing: 15) {
                    SummaryCard(
                        title: "Focus Time",
                        value: stats.time,
                        icon: "timer",
                        color: .blue
                    )
                    
                    SummaryCard(
                        title: "Sessions",
                        value: stats.sessions,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                SummaryCard(
                    title: "Productivity Score",
                    value: stats.score,
                    icon: "chart.bar.fill",
                    color: .orange
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
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
