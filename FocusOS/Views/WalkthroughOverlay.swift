import SwiftUI

struct WalkthroughOverlay: View {
    @ObservedObject var manager = WalkthroughManager.shared
    @Binding var activeTab: Tab
    @State private var pulse = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.5
    
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
                                    // The cutout with dynamic shape
                                    Group {
                                        switch manager.currentStep.shape {
                                        case .circle:
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: frame.width, height: frame.height)
                                                .position(x: frame.midX, y: frame.midY)
                                                .blendMode(.destinationOut)
                                        case .roundedRect(let cornerRadius):
                                            RoundedRectangle(cornerRadius: cornerRadius)
                                                .fill(Color.black)
                                                .frame(width: frame.width, height: frame.height)
                                                .position(x: frame.midX, y: frame.midY)
                                                .blendMode(.destinationOut)
                                        }
                                    }
                                }
                            }
                            .compositingGroup()
                        )
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // Block interaction with background
                        }
                    
                    // Spotlight Border with Enhanced Ripple
                    if let frame = anchorFrames[manager.currentStep] {
                        Group {
                            switch manager.currentStep.shape {
                            case .circle:
                                ZStack {
                                    // Ripple Layer 1 (Wide Wave)
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .scaleEffect(rippleScale)
                                        .opacity(rippleOpacity)
                                    
                                    // Ripple Layer 2 (Inner Wave)
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .scaleEffect(rippleScale * 0.8)
                                        .opacity(rippleOpacity * 0.8)
                                    
                                    // Core Border
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                        .shadow(color: Color.blue, radius: 10)
                                }
                                .frame(width: frame.width, height: frame.height)
                                .position(x: frame.midX, y: frame.midY)
                                .onAppear {
                                    withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                        rippleScale = 1.6
                                        rippleOpacity = 0.0
                                    }
                                }
                            case .roundedRect(let cornerRadius):
                                ZStack {
                                    // Ripple Layer 1 (Wide Wave)
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color.blue, lineWidth: 2)
                                        .scaleEffect(rippleScale)
                                        .opacity(rippleOpacity)
                                    
                                    // Ripple Layer 2 (Inner Wave)
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color.blue, lineWidth: 2)
                                        .scaleEffect(rippleScale * 0.8)
                                        .opacity(rippleOpacity * 0.8)
                                    
                                    // Core Border
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color.blue, lineWidth: 3)
                                        .shadow(color: Color.blue, radius: 10)
                                }
                                .frame(width: frame.width, height: frame.height)
                                .position(x: frame.midX, y: frame.midY)
                                .onAppear {
                                    withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                        rippleScale = 1.6
                                        rippleOpacity = 0.0
                                    }
                                }
                            }
                        }
                        
                        // Instructional Text & Controls
                        let isTopHalf = frame.midY < geometry.size.height / 2
                        
                        // Calculate horizontal position - center on element for iPad, screen center for iPhone
                        // Calculate horizontal position - center on element for iPad, screen center for iPhone
                        let textX: CGFloat = {
                            // Max width of text container is 320, so half width is 160
                            let halfWidth: CGFloat = 160
                            let padding: CGFloat = 20
                            
                            // Determine target X based on element position
                            var targetX = frame.midX
                            
                            // If element is in sidebar (left side), shift right
                            if frame.midX < geometry.size.width * 0.3 {
                                targetX = frame.midX + 180
                            }
                            
                            // Clamp to screen bounds
                            // Ensure left edge >= padding (targetX - halfWidth >= padding => targetX >= halfWidth + padding)
                            // Ensure right edge <= width - padding (targetX + halfWidth <= width - padding => targetX <= width - halfWidth - padding)
                            let minX = halfWidth + padding
                            let maxX = geometry.size.width - halfWidth - padding
                            
                            return min(max(targetX, minX), maxX)
                        }()
                        
                        // Calculate vertical position with clamping
                        let textY: CGFloat = {
                            let proposedY = isTopHalf ? frame.maxY + 120 : frame.minY - 120
                            let padding: CGFloat = 80
                            let minY = padding
                            let maxY = geometry.size.height - padding
                            return min(max(proposedY, minY), maxY)
                        }()
                        
                        VStack(spacing: 16) {
                            Text(manager.currentStep.title)
                                .font(.title3)
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
                                .padding()
                                
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
                        .position(
                            x: textX,
                            y: textY
                        )
                    }
                }
            }
            .transition(.opacity)
            .zIndex(999)
            .onChange(of: manager.currentStep) { _, newStep in
                if let requiredTab = newStep.requiredTab {
                    if activeTab != requiredTab {
                        withAnimation {
                            activeTab = requiredTab
                        }
                    }
                }
            }
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
