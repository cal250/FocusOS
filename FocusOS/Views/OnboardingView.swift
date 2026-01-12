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
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    var action: () -> Void
    
    let options = [
        ("Social Media", "iphone"),
        ("Notifications", "bell"),
        ("Noise", "speaker.wave.2"),
        ("Multitasking", "arrow.triangle.2.circlepath"),
        ("Daydreaming", "cloud")
    ]
    
    @State private var selectedOptions: Set<String> = []
    @State private var customHabit: String = ""
    @State private var showCustomInput: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("What usually breaks\nyour focus?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Select habits you want to track and overcome.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    // Predefined options
                    ForEach(options, id: \.0) { option, icon in
                        Button(action: {
                            toggleSelection(option)
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedOptions.contains(option) ? .white : .blue)
                                    .frame(width: 30)
                                
                                Text(option)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedOptions.contains(option) ? .white : .primary)
                                
                                Spacer()
                                
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(selectedOptions.contains(option) ? Color.blue : Color(UIColor.secondarySystemBackground))
                            )
                        }
                    }
                    
                    // Custom Habit Toggle/Input
                    if showCustomInput {
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                
                                TextField("Enter custom habit...", text: $customHabit)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                
                                Button(action: {
                                    withAnimation {
                                        showCustomInput = false
                                        customHabit = ""
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                showCustomInput = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Custom Habit")
                                Spacer()
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
            }
            
            Spacer()
            
            // Finish Button
            Button(action: {
                saveAndFinish()
            }) {
                Text("Start Focusing")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
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
    
    private func saveAndFinish() {
        // 1. Add selected predefined habits
        for option in selectedOptions {
            let icon = options.first(where: { $0.0 == option })?.1 ?? "circle"
            habitsViewModel.addHabit(name: option, icon: icon)
        }
        
        // 2. Add custom habit if valid
        let cleanedCustom = customHabit.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanedCustom.isEmpty {
            habitsViewModel.addHabit(name: cleanedCustom, icon: "star.fill")
        }
        
        // 3. Complete onboarding
        action()
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
