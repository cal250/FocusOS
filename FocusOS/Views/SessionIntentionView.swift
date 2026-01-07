import SwiftUI

// Update signature at top of file separately if needed, but I can replace the struct content
struct SessionIntentionView: View {
    var onStart: (String?, TimeInterval?) -> Void // Updated signature
    var onCancel: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    let options = ["Studying", "Coding", "Reading", "Writing", "Deep work", "Custom"]
    
    @State private var selectedOption: String?
    @State private var customIntention: String = ""
    
    // Timer State
    @State private var isOpenEnded = true
    @State private var selectedHours = 0
    @State private var selectedMinutes = 25
    
    var body: some View {
        VStack(spacing: 25) {
            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 15)
            
            VStack(spacing: 8) {
                Text("What are you focusing on?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Distractions happen. Just log them and return.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            
            // Chips Logic
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation {
                            selectedOption = option
                        }
                    }) {
                        Text(option)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedOption == option ? .white : .primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedOption == option ? Color.blue : Color(UIColor.secondarySystemBackground))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Custom Input
            if selectedOption == "Custom" {
                TextField("Enter your focus...", text: $customIntention)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Divider().padding(.horizontal, 20)
            
            // Duration Selection
            VStack(spacing: 15) {
                Toggle("Open Ended Session", isOn: $isOpenEnded)
                    .padding(.horizontal, 30)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                if !isOpenEnded {
                    HStack {
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0..<12) { h in
                                Text("\(h) h").tag(h)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100, height: 100)
                        .clipped()
                        
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<60) { m in
                                Text("\(m) m").tag(m)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100, height: 100)
                        .clipped()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            Spacer()
            
            // Subtle Alert / Info
            HStack(spacing: 6) {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.orange)
                Text("Your notifications will be silenced.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 5)
            
            // Start Button
            Button(action: {
                let finalTag = (selectedOption == "Custom") ? customIntention : selectedOption
                
                var duration: TimeInterval? = nil
                if !isOpenEnded {
                    duration = TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
                    if duration == 0 { duration = nil } // Safety check, treat as open if 0
                }
                
                onStart(finalTag, duration)
            }) {
                Text(startBtnText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            .disabled(selectedOption == nil || (selectedOption == "Custom" && customIntention.isEmpty))
            .opacity((selectedOption == nil || (selectedOption == "Custom" && customIntention.isEmpty)) ? 0.6 : 1.0)
        }
        .background(Color(UIColor.systemBackground))
        .padding(.bottom, 20) 
    }
    
    var startBtnText: String {
        if !isOpenEnded && (selectedHours > 0 || selectedMinutes > 0) {
            return "Start Timer"
        } else {
            return "Start Session"
        }
    }
}

struct SessionIntentionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionIntentionView(onStart: { _, _ in }, onCancel: {})
    }
}
