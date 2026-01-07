import SwiftUI

struct OnboardingView: View {
    var onFinished: () -> Void
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                WelcomePage(
                    action: {
                        withAnimation {
                            currentPage = 1
                        }
                    },
                    onSkip: {
                        withAnimation {
                            onFinished()
                        }
                    }
                )
                .tag(0)
                
                // Page 2: How It Works
                HowItWorksPage(
                    action: {
                        withAnimation {
                            currentPage = 2
                        }
                    },
                    onSkip: {
                        withAnimation {
                            onFinished()
                        }
                    }
                )
                .tag(1)
                
                // Page 3: Focus Breakers
                FocusBreakersPage(action: {
                    withAnimation {
                        onFinished()
                    }
                })
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Page 1: Welcome
struct WelcomePage: View {
    var action: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Illustration
                Image("undraw_personal-goals_f9bb")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .padding()
                
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
                
                // Forward Arrow Button
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Skip Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                Spacer()
            }
        }
    }
}

// MARK: - Page 2: How It Works
struct HowItWorksPage: View {
    var action: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("How FocusOS Works")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("A simple loop for mindful productivity.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                VStack(spacing: 24) {
                    OnboardingStepRow(
                        icon: "timer",
                        title: "Focus",
                        description: "Start a session and focus on your task."
                    )
                    
                    OnboardingStepRow(
                        icon: "pencil.circle",
                        title: "Log distractions",
                        description: "If your mind wanders, quickly log it."
                    )
                    
                    OnboardingStepRow(
                        icon: "chart.bar.fill",
                        title: "Reflect",
                        description: "Review your patterns and improve."
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Forward Arrow Button
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Skip Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                Spacer()
            }
        }
    }
}

// MARK: - Page 3: Focus Breakers
struct FocusBreakersPage: View {
    var action: () -> Void
    
    let options = [
        "Social Media", "Notifications", "Noise",
        "Multitasking", "Daydreaming", "Other"
    ]
    
    @State private var selectedOptions: Set<String> = []
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("What usually breaks\nyour focus?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 20)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 15)], spacing: 15) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        toggleSelection(option)
                    }) {
                        Text(option)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(selectedOptions.contains(option) ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(selectedOptions.contains(option) ? Color.blue : Color(UIColor.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Finish Button
            Button(action: action) {
                Text("Continue") // "Continue" as requested, effectively finish
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
    
    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

struct OnboardingStepRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinished: {})
    }
}
