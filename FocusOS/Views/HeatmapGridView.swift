import SwiftUI

struct HeatmapGridView: View {
    let dailyStats: [DailyStat]
    let endDate: Date
    
    // Config
    private let rows = 7
    private let spacing: CGFloat = 4
    private let cellSize: CGFloat = 12
    private let calendar = Calendar.current
    
    @State private var selectedStat: DailyStat?
    @State private var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus History")
                .font(.headline)
                .padding(.horizontal)
            
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - 32 // Padding
                let columns = Int(availableWidth / (cellSize + spacing))
                let daysToDisplay = columns * rows
                
                // Calculate start date based on dynamic count
                let startDate = calendar.date(byAdding: .day, value: -daysToDisplay, to: endDate) ?? endDate
                
                ZStack(alignment: .top) {
                    LazyHGrid(rows: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: rows), spacing: spacing) {
                        ForEach(0..<daysToDisplay, id: \.self) { offset in
                            if let date = calendar.date(byAdding: .day, value: -((daysToDisplay - 1) - offset), to: endDate) {
                                let startOfDay = calendar.startOfDay(for: date)
                                let stat = dailyStats.first(where: {
                                    if let statDate = dateFormatter.date(from: $0.date) {
                                        return calendar.isDate(statDate, inSameDayAs: startOfDay)
                                    }
                                    return false
                                })
                                
                                heatmapCell(for: date, stat: stat)
                            }
                        }
                    }
                    .frame(height: CGFloat(rows) * (cellSize + spacing))
                    
                    // Tooltip Overlay
                    if let selected = selectedStat, let date = selectedDate {
                        tooltipView(for: selected, date: date)
                            .offset(y: -50) // Show above grid
                            .transition(.opacity)
                    }
                }
                .position(x: geometry.size.width / 2, y: (CGFloat(rows) * (cellSize + spacing)) / 2)
            }
            .frame(height: CGFloat(rows) * (cellSize + spacing) + 20) // Fixed height container
            
            legendView
                .padding(.horizontal)
        }
        .padding(.vertical)
        .grassyCard(cornerRadius: 16)
    }
    
    // MARK: - Subviews
    
    func heatmapCell(for date: Date, stat: DailyStat?) -> some View {
        let intensity = calculateIntensity(for: stat)
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(color(for: intensity))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
            .onTapGesture {
                withAnimation {
                    if selectedDate == date {
                        selectedDate = nil
                        selectedStat = nil
                    } else {
                        selectedDate = date
                        selectedStat = stat ?? DailyStat(userId: UUID(), date: dateFormatter.string(from: date), totalFocusTime: 0, sessionCount: 0, avgProductivityScore: 0, distractionCount: 0)
                    }
                }
            }
    }
    
    func tooltipView(for stat: DailyStat, date: Date) -> some View {
        VStack(spacing: 4) {
            Text(date, style: .date)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if stat.sessionCount > 0 {
                Text("\(stat.sessionCount) sessions")
                    .font(.caption2)
                    .foregroundColor(.white)
                Text("Score: \(Int(stat.avgProductivityScore))%")
                    .font(.caption2)
                    .foregroundColor(color(for: calculateIntensity(for: stat)))
            } else {
                Text("No activity")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
        .shadow(radius: 4)
        .zIndex(1)
    }
    
    var legendView: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ForEach(0..<5) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color(for: level))
                    .frame(width: 10, height: 10)
            }
            
            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Logic
    
    func calculateIntensity(for stat: DailyStat?) -> Int {
        guard let stat = stat else { return 0 }
        if stat.sessionCount == 0 { return 0 }
        
        if stat.avgProductivityScore >= 80 { return 4 } // Great
        if stat.avgProductivityScore >= 60 { return 3 } // Good
        if stat.avgProductivityScore >= 40 { return 2 } // Okay
        return 1 // Low
    }
    
    func color(for level: Int) -> Color {
        switch level {
        case 0: return Color.gray.opacity(0.2) // Empty
        case 1: return Color(hex: "fbe9e7") // Weak
        case 2: return Color(hex: "c8e6c9") // Light Green
        case 3: return Color(hex: "81c784") // Medium Green
        case 4: return Color(hex: "388e3c") // Dark Green
        default: return Color.gray.opacity(0.2)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

// Color Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
