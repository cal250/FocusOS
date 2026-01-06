import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    
    // Placeholder version
    let appVersion = "1.0.0"
    
    var body: some View {
        NavigationView {
            List {
                // Preferences Section
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.purple)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            Text("Dark Mode")
                        }
                    }
                    
                    Toggle(isOn: $hapticsEnabled) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.blue)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "waveform")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            Text("Haptic Feedback")
                        }
                    }
                }
                
                // Privacy Section
                Section(header: Text("Privacy")) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("All data is stored securely on your device. We do not track your activity or collect any analytics.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Application")
                        Spacer()
                        Text("FocusOS")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("A focus and habit reflection app for students.")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            // Apply padding to avoid overlap with custom tab bar
            .padding(.bottom, 60)
        }
        // Force color scheme based on selection for demo
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
