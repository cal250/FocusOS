import SwiftUI

// MARK: - Grassy Theme Modifiers (iPad Only)

/// Applies a calm, organic "grassy" surface aesthetic using Apple-native materials
/// Only active on iPad (horizontalSizeClass == .regular)
struct GrassySurfaceModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var breathingPhase: CGFloat = 0
    
    let cornerRadius: CGFloat
    let material: Material
    
    init(cornerRadius: CGFloat = 28, material: Material = .thinMaterial) {
        self.cornerRadius = cornerRadius
        self.material = material
    }
    
    func body(content: Content) -> some View {
        let isIPad = horizontalSizeClass == .regular
        
        content
            .background(
                ZStack {
                    if isIPad {
                        // Material background - Force white for clean grassy aesthetic
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(UIColor.systemBackground))
                        
                        // Soft organic gradient overlay
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.08 * breathingPhase),
                                Color.blue.opacity(0.12 * (1 - breathingPhase)),
                                Color.teal.opacity(0.10 * breathingPhase)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                }
            )
            .onAppear {
                if isIPad {
                    withAnimation(
                        .easeInOut(duration: 12)
                        .repeatForever(autoreverses: true)
                    ) {
                        breathingPhase = 1.0
                    }
                }
            }
    }
}

/// Applies grassy card styling with material background and subtle gradient
struct GrassyCardModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var breathingPhase: CGFloat = 0
    
    let cornerRadius: CGFloat
    let material: Material
    let addShadow: Bool
    
    init(cornerRadius: CGFloat = 24, material: Material = .regularMaterial, addShadow: Bool = true) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.addShadow = addShadow
    }
    
    func body(content: Content) -> some View {
        let isIPad = horizontalSizeClass == .regular
        
        content
            .background(
                ZStack {
                    if isIPad {
                        // Material background
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(material)
                        
                        // Subtle gradient
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.06 * breathingPhase),
                                Color.blue.opacity(0.08 * (1 - breathingPhase))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else {
                        // iPhone: Use existing styling (secondarySystemBackground)
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(UIColor.secondarySystemBackground))
                    }
                }
            )
            .shadow(
                color: isIPad && addShadow ? Color.black.opacity(0.08) : .clear,
                radius: 12,
                x: 0,
                y: 4
            )
            .onAppear {
                if isIPad {
                    withAnimation(
                        .easeInOut(duration: 15)
                        .repeatForever(autoreverses: true)
                    ) {
                        breathingPhase = 1.0
                    }
                }
            }
    }
}

/// Applies a soft glow effect for active/selected states
struct GrassyGlowModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let isActive: Bool
    let cornerRadius: CGFloat
    
    init(isActive: Bool, cornerRadius: CGFloat = 16) {
        self.isActive = isActive
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        let isIPad = horizontalSizeClass == .regular
        
        content
            .background(
                ZStack {
                    if isIPad && isActive {
                        // Material glow background
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Material.ultraThinMaterial)
                        
                        // Soft blue/green glow
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.18),
                                        Color.teal.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies grassy surface styling (iPad only)
    /// - Parameters:
    ///   - cornerRadius: Corner radius for the surface (default: 28)
    ///   - material: Material type (default: .thinMaterial)
    func grassySurface(cornerRadius: CGFloat = 28, material: Material = .thinMaterial) -> some View {
        modifier(GrassySurfaceModifier(cornerRadius: cornerRadius, material: material))
    }
    
    /// Applies grassy card styling (iPad only, falls back to secondarySystemBackground on iPhone)
    /// - Parameters:
    ///   - cornerRadius: Corner radius for the card (default: 24)
    ///   - material: Material type (default: .regularMaterial)
    ///   - addShadow: Whether to add shadow (default: true)
    func grassyCard(cornerRadius: CGFloat = 24, material: Material = .regularMaterial, addShadow: Bool = true) -> some View {
        modifier(GrassyCardModifier(cornerRadius: cornerRadius, material: material, addShadow: addShadow))
    }
    
    /// Applies grassy glow effect for active states (iPad only)
    /// - Parameters:
    ///   - isActive: Whether the element is active/selected
    ///   - cornerRadius: Corner radius for the glow (default: 16)
    func grassyGlow(isActive: Bool, cornerRadius: CGFloat = 16) -> some View {
        modifier(GrassyGlowModifier(isActive: isActive, cornerRadius: cornerRadius))
    }
}
