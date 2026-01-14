import SwiftUI

struct WalkthroughOverlay: View {
    @ObservedObject var manager = WalkthroughManager.shared
    @Binding var activeTab: Tab
    @State private var pulse = false
    
    // We receive the anchor rects via preference key
    var anchorFrames: [WalkthroughStep: CGRect]
    
    var body: some View {
        if manager.isActive {
            GeometryReader { geometry in
                ZStack {
                    // Darker "Mirror" Background
                    Color.black.opacity(0.85)
                        .mask(
                            ZStack {
                                Rectangle().fill(Color.white)
                                
                                if let frame = anchorFrames[manager.currentStep] {
                                    // The cutout
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black)
                                        .frame(width: frame.width, height: frame.height)
                                        .position(x: frame.midX, y: frame.midY)
                                        .blendMode(.destinationOut)
                                }
                            }
                            .compositingGroup()
                        )
                        .edgesIgnoringSafeArea(.all) // Keep this for the Color fill
                        .onTapGesture {
                            // Block interaction with background
                        }
                    
                    // Spotlight Border with Pulsing Blue Glow
                    if let frame = anchorFrames[manager.currentStep] {
                        ZStack {
                            // Outer glow
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 4)
                                .shadow(color: Color.blue, radius: pulse ? 10 : 2) // Adjusted shadow for tighter feel
                                .opacity(pulse ? 1.0 : 0.6) // Brighter pulse
                            
                            // No inner white border needed if hugging tight? 
                            // User asked for "blue cole border". Let's stick to just the blue glow or simple border.
                            // The previous inner white border might look weird if perfectly tight.
                            // Let's keep it simple: Pulsing blue stroke.
                        }
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                        .onAppear {
                            pulse = true
                        }
                        
                        // Instructional Text & Controls
                        // Calculate position based on the frame (above or below)
                        let isTopHalf = frame.midY < geometry.size.height / 2
                        
                        VStack(spacing: 16) {
                            Text(manager.currentStep.title)
                                .font(.title3) // Larger title
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(manager.currentStep.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                            
                            HStack(spacing: 20) {
                                Button("Skip") {
                                    manager.skip()
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                
                                Button(action: {
                                    manager.next()
                                }) {
                                    Text("Next")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue)
                                                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                        )
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .frame(maxWidth: 320)
                        // Position logic: if low on screen, put text above. If high, put below.
                        .position(
                            x: geometry.size.width / 2,
                            y: isTopHalf ? frame.maxY + 120 : frame.minY - 120
                        )
                    }
                }
            }
            .transition(.opacity)
            .zIndex(999) // Ensure it's on top
            .onChange(of: manager.currentStep) { _, newStep in
                // Automatically switch tabs if the step requires it
                if let requiredTab = newStep.requiredTab {
                    if activeTab != requiredTab {
                        withAnimation {
                            activeTab = requiredTab
                        }
                    }
                }
            }
            // Ensure first tab is correct on start
            .onAppear {
                if let requiredTab = manager.currentStep.requiredTab, activeTab != requiredTab {
                    activeTab = requiredTab
                }
            }
        }
    }
}

// Preference Key to collect anchor frames
struct WalkthroughAnchorKey: PreferenceKey {
    static var defaultValue: [WalkthroughStep: CGRect] = [:]
    
    static func reduce(value: inout [WalkthroughStep: CGRect], nextValue: () -> [WalkthroughStep: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

extension View {
    func walkthroughAnchor(_ step: WalkthroughStep) -> some View {
        self.anchorPreference(key: WalkthroughAnchorKey.self, value: .bounds) { anchor in
            // We'll resolve this later with GeometryProxy
            // But we actually need the Anchor to create a Preference, 
            // handling Anchors in the overlay is complex. 
            // Simpler approach: Use background Query to get global frame?
            // "AnchorPreferences" is the "correct" way but requires the Overlay to have access to the source views' geometry context.
            // Let's use a GeometryReader helper for simplicity in this modifier to send global CGRects.
            return [:] // Placeholder, actual implementation below
        }
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: WalkthroughAnchorKey.self,
                    value: [step: geo.frame(in: .global)]
                )
            }
        )
    }
}
