import Foundation

struct UserData: Codable, Identifiable {
    var id: String?
    let email: String
    var remainingCredits: Int
}
