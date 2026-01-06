import Foundation

struct Distraction: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let description: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), description: String) {
        self.id = id
        self.timestamp = timestamp
        self.description = description
    }
}
