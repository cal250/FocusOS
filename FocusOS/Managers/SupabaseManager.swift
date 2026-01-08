import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Replace these with your actual Supabase credentials
    private let supabaseURL = URL(string: "https://ewdmbgeothlmigdblyok.supabase.co")!
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3ZG1iZ2VvdGhsbWlnZGJseW9rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3MTQwNDAsImV4cCI6MjA4MzI5MDA0MH0.CCuWIxt6Hjo9OKAdcC8TQDEXDiYI2gL_S8pdx7rgaXM"
    
    let client: SupabaseClient
    
    @Published var currentUser: User?
    @Published var session: Session?
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey)
        
        Task {
            await checkSession()
            
            for await (_, sessionUpdate) in client.auth.authStateChanges {
                await MainActor.run {
                    self.session = sessionUpdate
                    self.currentUser = sessionUpdate?.user
                }
            }
        }
    }
    
    @MainActor
    func checkSession() async {
        let session = try? await client.auth.session
        self.session = session
        self.currentUser = session?.user
    }
    
    @MainActor
    func signUp(email: String, password: String, fullName: String) async throws {
        print("Supabase: Signing up \(email)...")
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(fullName)]
        )
        self.session = response.session
        self.currentUser = response.user
        print("Supabase: Sign up successful. User ID: \(response.user.id)")
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        print("Supabase: Signing in \(email)...")
        let response = try await client.auth.signIn(
            email: email,
            password: password
        )
        self.session = response
        self.currentUser = response.user
        print("Supabase: Sign in successful. User ID: \(response.user.id)")
    }
    
    @MainActor
    func signOut() async throws {
        print("SupabaseManager: Signing out...")
        try await client.auth.signOut()
        self.session = nil
        self.currentUser = nil
        print("SupabaseManager: Sign out cleanup complete")
    }
    
    @MainActor
    func deleteAccount() async throws {
        guard let userId = currentUser?.id else {
            print("SupabaseManager: No user for deleteAccount")
            return
        }
        
        print("SupabaseManager: Deleting account for \(userId)...")
        
        do {
            // We call a Postgres function 'delete_user' which must be created in Supabase
            // with SECURITY DEFINER to allow the user to delete their own auth record.
            try await client.rpc("delete_user").execute()
            
            // Clean up local state
            self.session = nil
            self.currentUser = nil
            print("SupabaseManager: Account deletion successful")
        } catch {
            print("SupabaseManager: DELETE ACCOUNT ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    // MARK: - Daily Stats
    
    func fetchDailyStats(for date: Date) async throws -> DailyStat? {
        guard let userId = currentUser?.id else {
            print("SupabaseManager: No user for fetchDailyStats")
            return nil
        }
        
        let dateString = formatDate(date)
        print("SupabaseManager: Fetching stats for \(dateString)...")
        
        do {
            let stats: [DailyStat] = try await client
                .from("daily_stats")
                .select()
                .eq("user_id", value: userId)
                .eq("date", value: dateString)
                .execute()
                .value
            
            print("SupabaseManager: Fetch successful, found \(stats.count) records for \(dateString)")
            return stats.first
        } catch {
            print("SupabaseManager: FETCH ERROR for \(dateString): \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    func upsertDailyStat(_ stat: DailyStat) async throws {
        print("SupabaseManager: Upserting stats for \(stat.date)...")
        do {
            try await client
                .from("daily_stats")
                .upsert(stat)
                .execute()
            print("SupabaseManager: Upsert successful for \(stat.date)")
        } catch {
            print("SupabaseManager: UPSERT ERROR for \(stat.date): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Sessions
    
    func fetchSessions() async throws -> [StudySession] {
        guard let userId = currentUser?.id else {
            print("SupabaseManager: No user for fetchSessions")
            return []
        }
        
        print("SupabaseManager: Fetching sessions for \(userId)...")
        
        do {
            let sessions: [StudySession] = try await client
                .from("sessions")
                .select()
                .eq("user_id", value: userId)
                .order("start_time", ascending: false)
                .execute()
                .value
            
            print("SupabaseManager: Fetch successful, found \(sessions.count) sessions for user \(userId)")
            return sessions
        } catch {
            print("SupabaseManager: FETCH SESSIONS ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    func saveSession(_ session: StudySession) async throws {
        print("SupabaseManager: Saving session \(session.id)...")
        
        // Ensure user ID is set
        var sessionToSave = session
        if sessionToSave.userId == nil {
            sessionToSave.userId = currentUser?.id
        }
        
        do {
            try await client
                .from("sessions")
                .upsert(sessionToSave)
                .execute()
            print("SupabaseManager: Session save successful for \(session.id)")
        } catch {
            print("SupabaseManager: SAVE SESSION ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    // MARK: - Habits
    
    func fetchHabits() async throws -> [Habit] {
        guard let userId = currentUser?.id else {
            print("SupabaseManager: No user for fetchHabits")
            return []
        }
        
        print("SupabaseManager: Fetching habits for user \(userId)...")
        
        do {
            let habits: [Habit] = try await client
                .from("habits")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            print("SupabaseManager: Fetch successful, found \(habits.count) habits")
            return habits
        } catch {
            print("SupabaseManager: FETCH HABITS ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    func saveHabit(_ habit: Habit) async throws {
        print("SupabaseManager: Saving habit \(habit.name)...")
        
        var habitToSave = habit
        if habitToSave.userId == nil {
            habitToSave.userId = currentUser?.id
        }
        
        do {
            try await client
                .from("habits")
                .upsert(habitToSave)
                .execute()
            print("SupabaseManager: Habit save successful")
        } catch {
            print("SupabaseManager: SAVE HABIT ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    func deleteHabit(_ habitId: UUID) async throws {
        print("SupabaseManager: Deleting habit \(habitId)...")
        
        do {
            try await client
                .from("habits")
                .delete()
                .eq("id", value: habitId)
                .execute()
            print("SupabaseManager: Habit deletion successful")
        } catch {
            print("SupabaseManager: DELETE HABIT ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    func clearAllUserData() async throws {
        guard let userId = currentUser?.id else {
            print("SupabaseManager: No user for clearAllUserData")
            return
        }
        
        print("SupabaseManager: Clearing all data for user \(userId)...")
        
        do {
            // Delete from all tables
            try await client.from("sessions").delete().eq("user_id", value: userId).execute()
            try await client.from("habits").delete().eq("user_id", value: userId).execute()
            try await client.from("daily_stats").delete().eq("user_id", value: userId).execute()
            
            print("SupabaseManager: All user data cleared successfully")
        } catch {
            print("SupabaseManager: CLEAR ALL DATA ERROR: \(error.localizedDescription)")
            print("SupabaseManager Details: \(error)")
            throw error
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
