import Foundation

struct Habit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
}
