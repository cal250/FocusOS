import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingLogger = false
    @State private var showingIntentionSheet = false
    @State private var rotation: Double = 0
    
    // Gradient definitions to match the "Focus Period" aesthetic
    let ringGradient = AngularGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.6, blue: 1.0), // Blue-ish
            Color(red: 0.8, green: 0.5, blue: 1.0), // Purple-ish
            Color(red: 1.0, green: 0.6, blue: 0.4), // Orange-ish
            Color(red: 0.4, green: 0.6, blue: 1.0)  // Loop back to Blue
        ]),
        center: .center
    )
    
    let textGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.6, blue: 1.0),
            Color(red: 0.9, green: 0.5, blue: 0.7)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        let isIPad = horizontalSizeClass == .regular
        
        ZStack {
            // Background
            if isIPad {
                Color.clear
                    .grassySurface(cornerRadius: 0)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 40) {
                // Header
                Text("Focus Period")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundColor(Color.primary.opacity(0.8))
                    .padding(.top, 40)
                
                // Timer & Ring
                ZStack {
                    // Background Ticks (Gray)
                    TickRing(color: Color.gray.opacity(0.2))
                    
                    // Progress Ticks (Gradient with Animation)
                    TickRing(gradient: ringGradient)
                        .rotationEffect(.degrees(rotation))
                        .mask(
                            Circle().stroke(lineWidth: 40)
                        )
                        .onAppear {
                            // Start animation loop, but it only visually rotates if we change 'rotation'
                            // We trigger this based on session state or just always nice slow rotation
                        }
                        .onChange(of: viewModel.isSessionActive) { _, isActive in
                            if isActive && !viewModel.isPaused {
                                startAnimation()
                            } else {
                                stopAnimation()
                            }
                        }
                        .onChange(of: viewModel.isPaused) { _, isPaused in
                            if !isPaused && viewModel.isSessionActive {
                                startAnimation()
                            } else {
                                stopAnimation()
                            }
                        }

                    // Inner Content
                    VStack(spacing: 5) {
                        Image(systemName: viewModel.isSessionActive ? "checkmark.circle.fill" : "hourglass")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.isSessionActive ? .green : .gray)
                            .opacity(viewModel.isSessionActive ? 1.0 : 0.5)

                        // Gradient Text Timer (Reduced Size)
                        Text(viewModel.formattedElapsedTime())
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .overlay(
                                textGradient.mask(
                                    Text(viewModel.formattedElapsedTime())
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                )
                            )
                        
                        // Inner Status Text
                        Text(innerStatusText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                
                Spacer()
                
                // Controls
                if viewModel.isSessionActive {
                    HStack(spacing: 40) {
                        // Pause/Resume
                        Button(action: {
                            if viewModel.isPaused {
                                viewModel.resumeSession()
                            } else {
                                viewModel.pauseSession()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Stop
                        Button(action: {
                            viewModel.endSession()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                } else {
                    // Start Button
                    Button(action: {
                        showingIntentionSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 10)
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 3) // Visual centering
                        }
                    }
                    .walkthroughAnchor(.startFocus)
                }
                
                Spacer()
                
                // Bottom Status / Distraction Button
                if viewModel.isSessionActive {
                    Button(action: {
                        showingLogger = true
                    }) {
                        Text("Log Distraction")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.bottom, 100)
                    }
                } else {
                    Text("Ready to Start?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showingLogger) {
            DistractionLoggerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingIntentionSheet) {
            SessionIntentionView(
                onStart: { tag, duration in
                    showingIntentionSheet = false
                    viewModel.startSession(tag: tag, duration: duration)
                },
                onCancel: {
                    showingIntentionSheet = false
                }
            )
        }
        .alert(isPresented: $viewModel.showCongratulationAlert) {
            Alert(
                title: Text("Session Complete"),
                message: Text("Congratulations! You stayed focused."),
                dismissButton: .default(Text("Awesome"))
            )
        }
    }
    
    var innerStatusText: String {
        if viewModel.isSessionActive {
            return viewModel.isPaused ? "Paused" : "Focusing..."
        } else {
            return "Start Session"
        }
    }
    
    func startAnimation() {
        // If Open Ended: Rotate
        // If Duration Set: The TickRing handles progress via trim/mask if we pass it, 
        // but current implementation rotates the whole ring.
        // For simplicity/consistency with codebase, let's just keep rotating for now 
        // OR distinct logic. Let's keep rotating for "Active" state as it feels alive.
        withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    func stopAnimation() {
        withAnimation(.default) {
            rotation = 0 
        }
    }
}

// Helper View for the Dashed Ring
struct TickRing: View {
    var color: Color? = nil
    var gradient: AngularGradient? = nil
    
    let tickCount = 60
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let tickHeight = 15.0
            let tickWidth = 4.0
            
            ForEach(0..<tickCount, id: \.self) { index in
                Rectangle()
                    .fill(color ?? Color.white) // Use color if provided
                    .frame(width: tickWidth, height: tickHeight)
                    .offset(y: -radius + tickHeight / 2)
                    .rotationEffect(Angle.degrees(Double(index) / Double(tickCount) * 360))
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .ifLet(gradient) { view, grad in
            view.overlay(
                grad.mask(view)
            )
        }
    }
}

extension View {
    @ViewBuilder
    func ifLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}
