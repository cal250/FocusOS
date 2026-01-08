import Foundation
import Combine

class HabitsViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    
    private let supabaseManager = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchHabits()
        
        // Reload when user changes
        supabaseManager.$currentUser
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchHabits()
            }
            .store(in: &cancellables)
    }
    
    func fetchHabits() {
        guard supabaseManager.currentUser != nil else { return }
        
        isLoading = true
        Task {
            do {
                let fetchedHabits = try await supabaseManager.fetchHabits()
                await MainActor.run {
                    self.habits = fetchedHabits
                    self.isLoading = false
                }
            } catch {
                print("HabitsViewModel: Error fetching - \(error.localizedDescription)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    func addHabit(name: String, icon: String) {
        let newHabit = Habit(name: name, icon: icon)
        
        // Optimistic update
        habits.append(newHabit)
        
        Task {
            do {
                try await supabaseManager.saveHabit(newHabit)
            } catch {
                print("HabitsViewModel: Error adding - \(error.localizedDescription)")
                // Revert on failure
                fetchHabits()
            }
        }
    }
    
    func deleteHabit(at indexSet: IndexSet) {
        let habitsToDelete = indexSet.map { habits[$0] }
        
        // Optimistic update
        habits.remove(atOffsets: indexSet)
        
        Task {
            for habit in habitsToDelete {
                do {
                    try await supabaseManager.deleteHabit(habit.id)
                } catch {
                    print("HabitsViewModel: Error deleting - \(error.localizedDescription)")
                    fetchHabits() // Re-fetch to sync
                }
            }
        }
    }
}
