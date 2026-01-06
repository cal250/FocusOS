import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: (Habit) -> Void
    
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "iphone"
    
    let icons = [
        "iphone",
        "gamecontroller",
        "cart",
        "bed.double.fill",
        "tv",
        "bubble.left.and.bubble.right",
        "bolt",
        "brain.head.profile"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What habit do you want to break?", text: $habitName)
                }
                
                Section(header: Text("Icon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.blue : Color(UIColor.systemGray5))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon ? .white : .gray)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Add a Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save Habit") {
                    let newHabit = Habit(name: habitName, icon: selectedIcon)
                    onSave(newHabit)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .fontWeight(.bold)
            )
        }
    }
}
