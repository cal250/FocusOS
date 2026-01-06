import SwiftUI

@main
struct FocusOSApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(sessionViewModel)
        }
    }
}
