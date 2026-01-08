import Foundation

struct Habit: Identifiable, Codable {
    var id: UUID = UUID()
    var userId: UUID?
    let name: String
    let icon: String // SF Symbol name
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
    }
}
