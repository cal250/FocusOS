import SwiftUI

struct SplashScreenView: View {
    var onFinished: () -> Void
    
    // Wave States
    @State private var waveOffset: CGFloat = 1000 // Start below screen ("underground")
    @State private var wavePhase: CGFloat = 0.0
    @State private var waveOpacity: Double = 1.0
    
    // Ripple States
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.0
    @State private var rippleLineWidth: CGFloat = 10
    
    // Logo States
    @State private var logoScale: CGFloat = 0.0
    @State private var logoOpacity: Double = 0.0
    
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    // The Rising Tide (Wave)
                    // We use geometry reader or fixed frame for the wave container
                    ZStack(alignment: .bottom) {
                        Wave(phase: wavePhase, strength: 20)
                            .fill(Color.white)
                            .frame(width: 400, height: 200) // Adjust size as needed
                            .offset(y: waveOffset)
                            .opacity(waveOpacity)
                    }
                    .frame(height: 150) // Interaction area
                    .clipped() // Clip if needed, but we want it coming from bottom

                    // Ripples (Diffraction)
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: rippleLineWidth)
                            .scaleEffect(rippleScale)
                            .opacity(rippleOpacity)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: rippleLineWidth * 0.8)
                            .scaleEffect(rippleScale * 1.3)
                            .opacity(rippleOpacity * 0.7)
                            .frame(width: 100, height: 100)
                    }
                    
                    // Main Logo (Book Icon revealed)
                    Image("g8")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                .frame(height: 150)
                
                // Text
                Text("FocusOS")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .padding(.top, 40)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        // 1. Wave Rises (Tide flowing in)
        // Move from below screen to center (offset 0 relative to container or slightly higher)
        // Initial offset is 1000 (deep underground)
        
        // Animate Phase continuously for flow look (simulation)
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 4
        }
        
        // Rise Animation - Slower (2.5s)
        withAnimation(.easeInOut(duration: 2.5)) {
            waveOffset = 30 // Rise to roughly center
        }
        
        // 2. Impact / Diffraction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            // Wave dissipates
            withAnimation(.easeOut(duration: 0.2)) {
                waveOpacity = 0.0
            }
            
            // Ripples Expand
            rippleOpacity = 1.0
            withAnimation(.easeOut(duration: 1.5)) { // Slower ripple
                rippleScale = 3.5
                rippleOpacity = 0.0
                rippleLineWidth = 0
            }
        }
        
        // 3. Reveal Logo (Book)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        
        // 4. Reveal Text
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                textOpacity = 1.0
            }
        }
        
        // 5. Completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation {
                onFinished()
            }
        }
    }
}

// Custom Wave Shape
struct Wave: Shape {
    var phase: CGFloat
    var strength: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        // Drawing sine wave along the top
        path.move(to: CGPoint(x: 0, y: height)) // Start bottom-left
        path.addLine(to: CGPoint(x: 0, y: midHeight)) // Move to mid-left
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            // Sine calculation
            let sine = sin(relativeX * .pi * 2 + phase)
            let y = midHeight + (strength * sine)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height)) // To bottom-right
        path.closeSubpath() // Close back to bottom-left
        
        return path
    }
}
