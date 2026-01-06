import SwiftUI
import Charts

struct InsightsChartView: View {
    let pastSessions: [StudySession]
    
    var body: some View {
        VStack {
            Text("Focus History")
                .font(.headline)
            
            if pastSessions.isEmpty {
                Text("No sessions recorded yet.")
                    .foregroundStyle(.secondary)
                    .frame(height: 200)
            } else {
                Chart(pastSessions) { session in
                    LineMark(
                        x: .value("Date", session.startTime),
                        y: .value("Focus Score", session.focusScore)
                    )
                }
                .frame(height: 250)
                .padding()
            }
        }
    }
}
