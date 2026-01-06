import SwiftUI

struct OnboardingView: View {
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Illustration
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color.green.opacity(0.6)) // Soft sage green
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 200, height: 200)
                    )
                
                VStack(spacing: 16) {
                    // Title
                    Text("Focus, without pressure.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    // Description
                    Text("Experience productivity that adapts to your rhythm, not the other way around.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    withAnimation {
                        onFinished()
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinished: {})
    }
}
