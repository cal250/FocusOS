import SwiftUI
import UniformTypeIdentifiers

struct AccountView: View {
    @EnvironmentObject var viewModel: SessionViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @AppStorage("userName") private var userName = "Focus User"
    @AppStorage("userEmail") private var userEmail = "user@focusos.app"
    @State private var isEditingProfile = false
    @State private var showingClearDataAlert = false
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingExportSheet = false
    @State private var exportDocument: ExportDocument?
    @ObservedObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text(userInitials)
                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        if isEditingProfile {
                            TextField("Name", text: $userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 40)
                            
                            TextField("Email", text: $userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 40)
                        } else {
                            Text(supabaseManager.currentUser?.userMetadata["full_name"]?.value as? String ?? userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(supabaseManager.currentUser?.email ?? userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        if isEditingProfile {
                            // Saving changes
                            Task {
                                do {
                                    try await supabaseManager.updateProfile(fullName: userName)
                                } catch {
                                    print("AccountView: Failed to update profile - \(error.localizedDescription)")
                                }
                            }
                        } else {
                            // Starting edit - initialize with current name
                            if let currentName = supabaseManager.currentUser?.userMetadata["full_name"]?.value as? String {
                                userName = currentName
                            }
                        }
                        
                        withAnimation {
                            isEditingProfile.toggle()
                        }
                    }) {
                        Text(isEditingProfile ? "Done" : "Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
                .padding(.bottom, 10)
                
                Divider()
                    .padding(.horizontal)
                
                // Statistics Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Statistics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        StatRow(
                            icon: "chart.bar",
                            label: "Total Sessions",
                            value: "\(viewModel.pastSessions.count)",
                            color: .blue
                        )
                        
                        StatRow(
                            icon: "clock",
                            label: "Total Focus Time",
                            value: totalFocusTime,
                            color: .blue
                        )
                        
                        StatRow(
                            icon: "calendar.badge.clock",
                            label: "Member Since",
                            value: memberSince,
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Data & Account Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Data & Account")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ActionButton(
                            icon: "arrow.up.doc",
                            label: "Export Data",
                            color: .gray
                        ) {
                            exportData()
                        }
                        
                        ActionButton(
                            icon: "trash.slash",
                            label: "Clear All Data",
                            color: .gray
                        ) {
                            showingClearDataAlert = true
                        }
                        
                        ActionButton(
                            icon: "xmark.circle",
                            label: "Delete Account",
                            color: .gray
                        ) {
                            showingDeleteAccountAlert = true
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                
                                Text("Sign Out")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground))
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    do {
                        try await SupabaseManager.shared.clearAllUserData()
                        await MainActor.run {
                            viewModel.pastSessions.removeAll()
                            habitsViewModel.habits.removeAll()
                        }
                    } catch {
                        print("AccountView: Failed to clear data - \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("This will permanently delete all your session history. This action cannot be undone.")
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                print("AccountView: Signing out...")
                Task {
                    do {
                        try await supabaseManager.signOut()
                        print("AccountView: Sign Out successful")
                    } catch {
                        print("AccountView: Sign Out failed - \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                print("AccountView: Deleting account...")
                Task {
                    do {
                        try await supabaseManager.deleteAccount()
                        print("AccountView: Account deleted successful")
                    } catch {
                        print("AccountView: Account deletion failed - \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("This action is permanent and will delete all your data, sessions, and habits. You cannot undo this.")
        }
        .fileExporter(
            isPresented: $showingExportSheet,
            document: exportDocument,
            contentType: .html,
            defaultFilename: "FocusOS_Journey_\(formattedExportDate).html"
        ) { result in
            switch result {
            case .success(let url):
                print("Exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
        .onAppear {
            // Sync local name with database on load
            if let currentName = supabaseManager.currentUser?.userMetadata["full_name"]?.value as? String {
                userName = currentName
            }
        }
    }
    
    // MARK: - Functions
    
    func exportData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let totalSessions = viewModel.pastSessions.count
        let totalMinutes = Int(viewModel.pastSessions.reduce(0) { $0 + $1.duration } / 60)
        let totalHours = totalMinutes / 60
        let remainingMinutes = totalMinutes % 60
        
        var htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>FocusOS - Your Focus Journey</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    padding: 40px 20px;
                    color: #333;
                }
                .container {
                    max-width: 900px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 20px;
                    padding: 40px;
                    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                }
                .header {
                    text-align: center;
                    margin-bottom: 40px;
                    padding-bottom: 30px;
                    border-bottom: 2px solid #f0f0f0;
                }
                .header h1 {
                    font-size: 36px;
                    color: #667eea;
                    margin-bottom: 10px;
                }
                .header p {
                    font-size: 18px;
                    color: #666;
                }
                .stats {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 20px;
                    margin-bottom: 40px;
                }
                .stat-card {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    padding: 25px;
                    border-radius: 15px;
                    text-align: center;
                    color: white;
                }
                .stat-card h3 {
                    font-size: 14px;
                    opacity: 0.9;
                    margin-bottom: 10px;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
                .stat-card p {
                    font-size: 32px;
                    font-weight: bold;
                }
                .encouragement {
                    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                    padding: 30px;
                    border-radius: 15px;
                    text-align: center;
                    margin-bottom: 40px;
                    color: white;
                }
                .encouragement h2 {
                    font-size: 24px;
                    margin-bottom: 10px;
                }
                .encouragement p {
                    font-size: 16px;
                    opacity: 0.95;
                }
                .sessions {
                    margin-top: 30px;
                }
                .sessions h2 {
                    font-size: 24px;
                    color: #333;
                    margin-bottom: 20px;
                }
                .session-card {
                    background: #f8f9fa;
                    padding: 20px;
                    border-radius: 12px;
                    margin-bottom: 15px;
                    border-left: 4px solid #667eea;
                }
                .session-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 10px;
                }
                .session-tag {
                    font-size: 18px;
                    font-weight: bold;
                    color: #667eea;
                }
                .session-date {
                    font-size: 14px;
                    color: #666;
                }
                .session-details {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                    gap: 15px;
                    margin-top: 15px;
                }
                .detail {
                    font-size: 14px;
                    color: #666;
                }
                .detail strong {
                    color: #333;
                    display: block;
                    margin-bottom: 5px;
                }
                .perfect-session {
                    border-left-color: #4ade80;
                }
                .footer {
                    text-align: center;
                    margin-top: 40px;
                    padding-top: 30px;
                    border-top: 2px solid #f0f0f0;
                    color: #999;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🎯 Your Focus Journey</h1>
                    <p>Exported on \(formatter.string(from: Date()))</p>
                </div>
                
                <div class="stats">
                    <div class="stat-card">
                        <h3>Total Sessions</h3>
                        <p>\(totalSessions)</p>
                    </div>
                    <div class="stat-card">
                        <h3>Total Focus Time</h3>
                        <p>\(totalHours)h \(remainingMinutes)m</p>
                    </div>
                </div>
                
                <div class="encouragement">
                    <h2>✨ You're Making Progress!</h2>
                    <p>Every session is a step forward. Keep building your focus muscle, one session at a time.</p>
                </div>
                
                <div class="sessions">
                    <h2>📚 Session History</h2>
        """
        
        for session in viewModel.pastSessions.sorted(by: { $0.startTime > $1.startTime }) {
            let date = formatter.string(from: session.startTime)
            let startTime = formatter.string(from: session.startTime)
            let endTime = session.endTime != nil ? formatter.string(from: session.endTime!) : "Ongoing"
            let duration = Int(session.duration / 60)
            let tag = session.tag ?? "Focus Session"
            let distractionCount = session.distractions.count
            let isPerfect = distractionCount == 0
            
            htmlContent += """
                    <div class="session-card \(isPerfect ? "perfect-session" : "")">
                        <div class="session-header">
                            <div class="session-tag">\(isPerfect ? "✅ " : "")\(tag)</div>
                            <div class="session-date">\(date)</div>
                        </div>
                        <div class="session-details">
                            <div class="detail">
                                <strong>Duration</strong>
                                \(duration) minutes
                            </div>
                            <div class="detail">
                                <strong>Time</strong>
                                \(startTime) - \(endTime)
                            </div>
                            <div class="detail">
                                <strong>Distractions</strong>
                                \(distractionCount == 0 ? "Perfect focus! 🎉" : "\(distractionCount)")
                            </div>
                        </div>
                    </div>
            """
        }
        
        htmlContent += """
                </div>
                
                <div class="footer">
                    <p>Generated by FocusOS - Your mindful productivity companion</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        exportDocument = ExportDocument(content: htmlContent)
        showingExportSheet = true
    }
    
    // MARK: - Computed Properties
    
    var userInitials: String {
        let nameToUse = supabaseManager.currentUser?.userMetadata["full_name"]?.value as? String ?? userName
        let components = nameToUse.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    var totalFocusTime: String {
        let totalSeconds = viewModel.pastSessions.reduce(0) { $0 + $1.duration }
        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var memberSince: String {
        // Placeholder - could be stored in UserDefaults
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date().addingTimeInterval(-30 * 24 * 60 * 60)) // 30 days ago
    }
    
    var formattedExportDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountView()
                .environmentObject(SessionViewModel())
                .environmentObject(HabitsViewModel())
        }
    }
}

// MARK: - Export Document

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.html, .plainText] }
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            content = string
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
