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
    
    // Drag Gesture State
    @GestureState private var isDragging = false
    
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
                    // background for hit testing
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($isDragging) { _, state, _ in
                                    state = true
                                }
                                .onChanged { value in
                                    let location = value.location
                                    let gridHeight = CGFloat(rows) * (cellSize + spacing)
                                    let gridWidth = CGFloat(columns) * (cellSize + spacing)
                                    
                                    // Map location to indices
                                    if location.x >= 0 && location.x < gridWidth && location.y >= 0 && location.y < gridHeight {
                                        let col = Int(location.x / (cellSize + spacing))
                                        let row = Int(location.y / (cellSize + spacing))
                                        
                                        // Calculate date from row/col
                                        // The grid fills column by column? No, LazyHGrid fills rows first then columns?
                                        // Actually LazyHGrid with 'rows' fixed: fills Top-to-Bottom, Left-to-Right.
                                        // Index = col * rows + row
                                        
                                        let index = col * rows + row
                                        if index < daysToDisplay {
                                            // The grid renders from left to right (past -> future).
                                            // So the 0th index is the oldest date.
                                            // daysToDisplay - 1 is the endDate (bottom right).
                                            // Actually, implementation below renders:
                                            // ForEach(0..<daysToDisplay) ... date = endDate - daysToDisplay + 1 + offset
                                            // So 0 is passing to ForEach.
                                            
                                            // BUT LazyHGrid default flow:
                                            // Column 0: Row 0, Row 1, ... Row 6
                                            // Column 1: Row 0 ...
                                            
                                            if let date = calendar.date(byAdding: .day, value: -((daysToDisplay - 1) - index), to: endDate) {
                                                if selectedDate != date {
                                                    selectedDate = date
                                                    let startOfDay = calendar.startOfDay(for: date)
                                                    selectedStat = dailyStats.first(where: {
                                                        if let statDate = dateFormatter.date(from: $0.date) {
                                                            return calendar.isDate(statDate, inSameDayAs: startOfDay)
                                                        }
                                                        return false
                                                    })
                                                    // Haptic feedback on change
                                                    HapticManager.shared.playSelection()
                                                }
                                            }
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        selectedDate = nil
                                        selectedStat = nil
                                    }
                                }
                        )
                    
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
                    .allowsHitTesting(false) // Pass touches to ZStack gesture
                    
                    // Tooltip Overlay
                    if let date = selectedDate {
                        // Fallback stat if none exists
                        let stat = selectedStat ?? DailyStat(userId: UUID(), date: dateFormatter.string(from: date), totalFocusTime: 0, sessionCount: 0, avgProductivityScore: 0, distractionCount: 0)
                        
                        GrassyTooltip(stat: stat, date: date)
                            .offset(y: -130) // Show above grid
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .zIndex(100)
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
        let isSelected = selectedDate == date
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(color(for: intensity))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.blue : Color.black.opacity(0.1), lineWidth: isSelected ? 2 : 0.5)
            )
            .scaleEffect(isSelected ? 1.5 : 1.0)
            .animation(.spring(), value: isSelected)
    }
    
    struct GrassyTooltip: View {
        let stat: DailyStat
        let date: Date
        
        var body: some View {
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(date.formatted(.dateTime.weekday(.wide)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(date.formatted(.dateTime.month().day()))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                
                Divider()
                
                // Main Stat
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                    Text(formatTime(stat.totalFocusTime))
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                // Grid details
                HStack(spacing: 20) {
                    VStack {
                        Text("\(stat.sessionCount)")
                            .font(.headline)
                        Text("Sessions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider().frame(height: 20)
                    
                    VStack {
                        Text("\(Int(stat.avgProductivityScore))%")
                            .font(.headline)
                        Text("Score")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider().frame(height: 20)
                    
                    VStack {
                        Text("\(stat.distractionCount)")
                            .font(.headline)
                        Text("Distractions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(width: 250)
            .background(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1)) // Grassy tint
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
        }
        
        func formatTime(_ seconds: Int) -> String {
            if seconds == 0 { return "0m" }
            let h = seconds / 3600
            let m = (seconds % 3600) / 60
            if h > 0 { return "\(h)h \(m)m" }
            return "\(m)m"
        }
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
