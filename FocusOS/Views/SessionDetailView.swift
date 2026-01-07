import SwiftUI

struct SessionDetailView: View {
    let session: StudySession
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    if let tag = session.tag {
                        Text(tag)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    } else {
                        Text("Focus Session")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal)
                
                // Time Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Session Time")
                    
                    HStack(spacing: 40) {
                        TimeInfoRow(
                            label: "Started",
                            time: formattedTime(session.startTime)
                        )
                        
                        if let endTime = session.endTime {
                            TimeInfoRow(
                                label: "Ended",
                                time: formattedTime(endTime)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    InfoCard(
                        icon: "clock.fill",
                        label: "Duration",
                        value: formattedDuration,
                        color: .blue
                    )
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Distractions Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Distractions")
                    
                    if session.distractions.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("No distractions logged")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(session.distractions) { distraction in
                                DistractionRow(distraction: distraction)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Computed Properties
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: session.startTime)
    }
    
    var formattedDuration: String {
        let duration = session.duration
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal)
    }
}

struct TimeInfoRow: View {
    let label: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(time)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DistractionRow: View {
    let distraction: Distraction
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.orange)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(distraction.description)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: distraction.timestamp)
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SessionDetailView(session: StudySession(
                startTime: Date().addingTimeInterval(-3600),
                endTime: Date(),
                tag: "Deep Work",
                plannedDuration: 3600
            ))
        }
    }
}
