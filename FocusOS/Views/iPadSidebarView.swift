import SwiftUI

struct iPadSidebarView: View {
    @Binding var selectedTab: Tab
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Logo/Name
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("FocusOS")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Mindful Productivity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 40)
            
            // Navigation Sections
            VStack(spacing: 8) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    SidebarNavigationItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                                // Haptic feedback (respects user settings)
                                HapticManager.shared.playImpact(style: .light)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Footer (optional: version, settings link, etc.)
            VStack(spacing: 4) {
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                Text("v1.2 • iPad Edition")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 280)
        .grassySurface(cornerRadius: 0, material: .ultraThinMaterial)
    }
}

// MARK: - Sidebar Navigation Item

struct SidebarNavigationItem: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .frame(width: 28)
                
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .grassyGlow(isActive: isSelected, cornerRadius: 12)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct iPadSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        iPadSidebarView(selectedTab: .constant(.today))
            .previewLayout(.sizeThatFits)
    }
}
