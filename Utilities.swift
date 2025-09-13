import Foundation

class Utilities {
    static func isValidGuess(_ input: String) -> Bool {
        let validSet = Set("123456")
        return input.count == 4 && input.allSatisfy { validSet.contains($0) }
    }
}