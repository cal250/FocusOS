import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var hasAgreed = false
    @State private var isAppeared = false
    
    // Callback for when user accepts
    var onAccept: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Very light background
            Color(red: 0.98, green: 0.98, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Before You Begin")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    Spacer()
                    // Dummy spacer to balance back button
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Header Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                        }
                        .padding(.top, 20)
                        
                        // Main Title & Subtitle
                        VStack(spacing: 12) {
                            Text("FocusOS Ethical Agreement")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            
                            Text("Please review how FocusOS supports your productivity journey through discipline and awareness.")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .padding(.horizontal, 20)
                        }
                        
                        // What you should know card
                        VStack(alignment: .leading, spacing: 20) {
                            Text("What you should know:")
                                .font(.system(size: 18, weight: .bold))
                            
                            VStack(spacing: 24) {
                                InfoItem(
                                    icon: "target",
                                    title: "Purpose-Driven",
                                    content: "FocusOS helps you manage challenges through self-awareness and habit-building."
                                )
                                
                                InfoItem(
                                    icon: "shield.lefthalf.filled",
                                    title: "No Restrictions",
                                    content: "We don't block apps or lock devices. We encourage discipline through intentional choices."
                                )
                                
                                InfoItem(
                                    icon: "lock.shield",
                                    title: "Privacy Priority",
                                    content: "Your data is handled respectfully and used only to improve your focus experience."
                                )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                .background(Color.white)
                        )
                        .padding(.horizontal, 20)
                        
                        // Agreement Section
                        VStack(alignment: .leading, spacing: 20) {
                            // Toggle
                            Toggle(isOn: $hasAgreed) {
                                HStack(spacing: 4) {
                                    Text("I agree to the")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                                    Text("terms and conditions")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.25, green: 0.45, blue: 0.85)))
                            
                            // legal-ish text
                            Text("By agreeing, you acknowledge that FocusOS is a tool for self-discipline and you accept full responsibility for your usage and decisions. FocusOS is not a medical application.")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Button
                        Button(action: {
                            if hasAgreed {
                                onAccept?()
                                dismiss()
                            }
                        }) {
                            Text("Agree & Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(hasAgreed ? Color(red: 0.25, green: 0.45, blue: 0.85) : Color(red: 0.25, green: 0.45, blue: 0.85).opacity(0.5))
                                .cornerRadius(12)
                        }
                        .disabled(!hasAgreed)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Footer Links
                        HStack(spacing: 24) {
                            FooterLink(icon: "info.circle", text: "Privacy Policy")
                            FooterLink(icon: "questionmark.circle", text: "Need Help?")
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.bottom, 20)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                    .frame(maxWidth: .infinity) // Center the constrained view
                }
            }
        }
        .opacity(isAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAppeared = true
            }
        }
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FooterLink: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(text)
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
    }
}

#Preview {
    TermsAndConditionsView()
}

#Preview {
    TermsAndConditionsView()
}
