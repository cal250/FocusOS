import SwiftUI

struct HabitsView: View {
    // Mock Data init
    @State private var habits: [Habit] = [
        Habit(name: "Phone Scrolling", icon: "iphone"),
        Habit(name: "Daydreaming", icon: "bubble.left.and.bubble.right"),
        Habit(name: "Online Shopping", icon: "cart"),
        Habit(name: "Gaming", icon: "gamecontroller")
    ]
    
    @EnvironmentObject var viewModel: SessionViewModel
    
    var allDistractions: [Distraction] {
        var distractions = viewModel.pastSessions.flatMap { $0.distractions }
        if let current = viewModel.currentSession {
            distractions.append(contentsOf: current.distractions)
        }
        return distractions.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    @State private var showingAddHabit = false
    @State private var habitToDelete: Habit? = nil
    @State private var showingDeleteConfirmation = false
    
    // Formatting helper
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short // Added date context
        formatter.doesRelativeDateFormatting = true 
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Habits to Break")) {
                    ForEach(habits) { habit in
                        HStack {
                            Image(systemName: habit.icon)
                                .frame(width: 30)
                                .foregroundColor(.red)
                            Text(habit.name)
                                .fontWeight(.medium)
                        }
                    }
                    .onDelete { indexSet in
                        if let firstIndex = indexSet.first {
                            habitToDelete = habits[firstIndex]
                            showingDeleteConfirmation = true
                        }
                    }
                }
                
                Section(header: Text("Distraction History")) {
                    if allDistractions.isEmpty {
                        Text("No distractions logged yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(allDistractions) { distraction in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(distraction.description)
                                        .font(.body)
                                    Text(timeFormatter.string(from: distraction.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Habits")
            .navigationBarItems(trailing: Button(action: {
                showingAddHabit = true
            }) {
                Image(systemName: "plus")
                    .font(.body)
            })
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet { newHabit in
                    habits.append(newHabit)
                }
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Have you broken this habit?"),
                    message: Text("Removing this habit means you've successfully conquered it."),
                    primaryButton: .destructive(Text("Yes, I broke it!")) {
                        if let habit = habitToDelete {
                            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                                habits.remove(at: index)
                            }
                        }
                        habitToDelete = nil
                    },
                    secondaryButton: .cancel() {
                        habitToDelete = nil
                    }
                )
            }
            // Add padding at bottom to avoid overlap with custom TabBar
            // Add padding at bottom to avoid overlap with custom TabBar
            // List inherently handles safe area usually, but with our custom setup:
            .padding(.bottom, 60) 
        }
    }
}
