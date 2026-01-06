import SwiftUI

struct SummaryView: View {
    let session: StudySession
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Session Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(InsightEngine.generateSummary(for: session))
                .multilineTextAlignment(.center)
                .padding()
            
            HStack {
                VStack {
                    Text("Focus Score")
                        .font(.headline)
                    Text(String(format: "%.0f", session.focusScore))
                        .font(.title)
                        .foregroundColor(scoreColor(score: session.focusScore))
                }
                .padding()
                
                VStack {
                    Text("Duration")
                        .font(.headline)
                    Text("\(Int(session.duration / 60)) min")
                        .font(.title)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func scoreColor(score: Double) -> Color {
        if score > 80 { return .green }
        else if score > 50 { return .orange }
        else { return .red }
    }
}
