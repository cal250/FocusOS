import SwiftUI

struct HabitsView: View {
    // Mock Data
    let habits = [
        ("iphone", "Phone Scrolling"),
        ("bubble.left.and.bubble.right", "Daydreaming"),
        ("cart", "Online Shopping"),
        ("gamecontroller", "Gaming")
    ]
    
    let history = [
        ("10:45 AM", "Checked Twitter"),
        ("11:20 AM", "Replied to texts"),
        ("Yesterday", "Youtube Shorts spiral"),
        ("Yesterday", "Cat videos")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Habits to Break")) {
                    ForEach(habits, id: \.1) { icon, habit in
                        HStack {
                            Image(systemName: icon)
                                .frame(width: 30)
                                .foregroundColor(.red)
                            Text(habit)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section(header: Text("Distraction History")) {
                    ForEach(history, id: \.1) { time, description in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(description)
                                    .font(.body)
                                Text(time)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Habits")
            .navigationBarItems(trailing: Button(action: {
                // Placeholder action
                print("Add Habit")
            }) {
                Image(systemName: "plus")
                    .font(.body)
            })
            // Add padding at bottom to avoid overlap with custom TabBar
            // List inherently handles safe area usually, but with our custom setup:
            .padding(.bottom, 60) 
        }
    }
}
