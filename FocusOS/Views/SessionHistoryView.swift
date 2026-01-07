import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.pastSessions.isEmpty {
                    EmptyHistoryView()
                } else {
                    ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 12) {
                            // Date Header
                            Text(formatDateHeader(date))
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            // Sessions for this date
                            VStack(spacing: 12) {
                                ForEach(groupedSessions[date] ?? []) { session in
                                    NavigationLink(destination: SessionDetailView(session: session)) {
                                        SessionRow(session: session)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Session History")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Computed Properties
    
    var groupedSessions: [Date: [StudySession]] {
        let calendar = Calendar.current
        
        return Dictionary(grouping: viewModel.pastSessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
    }
    
    func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: StudySession
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Icon or Tag Initial
            ZStack {
                Circle()
                    .fill(tagColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                if let tag = session.tag, let first = tag.first {
                    Text(String(first).uppercased())
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(tagColor)
                } else {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
            
            // Middle: Session Info
            VStack(alignment: .leading, spacing: 6) {
                Text(session.tag ?? "Focus Session")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(timeRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right: Distraction Indicator
            if session.distractions.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green.opacity(0.7))
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange.opacity(0.7))
                    
                    Text("\(session.distractions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    var tagColor: Color {
        guard let tag = session.tag else { return .blue }
        
        let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .indigo]
        let index = abs(tag.hashValue) % colors.count
        return colors[index]
    }
    
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let start = formatter.string(from: session.startTime)
        
        if let end = session.endTime {
            let endStr = formatter.string(from: end)
            return "\(start) - \(endStr)"
        } else {
            return start
        }
    }
    
    var duration: String {
        let dur = session.duration
        let hours = Int(dur) / 3600
        let minutes = Int(dur) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Empty State

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Sessions Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your focus sessions will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHistoryView()
            .environmentObject(SessionViewModel())
    }
}
