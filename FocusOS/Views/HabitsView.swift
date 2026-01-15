import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitsViewModel: HabitsViewModel
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
            ZStack {
                List {
                    Section(header: Text("Habits to Break")) {
                        if habitsViewModel.habits.isEmpty && !habitsViewModel.isLoading {
                            Text("No habits added yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(habitsViewModel.habits) { habit in
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
                                    habitToDelete = habitsViewModel.habits[firstIndex]
                                    showingDeleteConfirmation = true
                                }
                            }
                        }
                    }
                    .walkthroughAnchor(.habitsSection)
                    
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
                
                if habitsViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationTitle("Habits")
            .navigationBarItems(trailing: Button(action: {
                showingAddHabit = true
            }) {
                Image(systemName: "plus")
                    .font(.body)
            })
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet { newHabit in
                    habitsViewModel.addHabit(name: newHabit.name, icon: newHabit.icon)
                }
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Have you broken this habit?"),
                    message: Text("Removing this habit means you've successfully conquered it."),
                    primaryButton: .destructive(Text("Yes, I broke it!")) {
                        if let habit = habitToDelete {
                            if let index = habitsViewModel.habits.firstIndex(where: { $0.id == habit.id }) {
                                habitsViewModel.deleteHabit(at: IndexSet(integer: index))
                            }
                        }
                        habitToDelete = nil
                    },
                    secondaryButton: .cancel() {
                        habitToDelete = nil
                    }
                )
            }
            .padding(.bottom, 60) 
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
