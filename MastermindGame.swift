import Foundation

class MastermindGame {
    private var gameID: String?

    func start() {
        print("Mastermind Game Started")
        print("To exit, enter 'exit'.\n")

        let semaphore = DispatchSemaphore(value: 0)

        print("Requesting to create game...")

        APIService.createGame { id in
            if let id = id {
                self.gameID = id
                print("Game ID: \(id)")
                print("Please enter a 4-digit code containing numbers 1 to 6.")
            } else {
                print("Error creating game.")
            }
            semaphore.signal()
        }

        semaphore.wait()

        self.gameLoop()
    }

    func gameLoop() {
        guard let gameID = gameID else {
            print("❌ Game ID not found.")
            return
        }

        while true {
            print("\n Your guess:", terminator: " ")

            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else {
                continue
            }

            if input.lowercased() == "exit" {
                print("Exit game. Good luck!")
                break
            }

            guard Utilities.isValidGuess(input) else {
                print("Invalid input! Guess must be exactly 4 numbers from 1 to 6.")
                continue
            }

            let guessSemaphore = DispatchSemaphore(value: 0)

            APIService.sendGuess(gameID: gameID, guess: input) { result in
                if let result = result {
                    let b = String(repeating: "B", count: result.black)
                    let w = String(repeating: "W", count: result.white)
                    print("Response: \(b)\(w)  [\(result.black) black, \(result.white) white]")
                } else {
                    print("Your guess was not sent. Try again.")
                }
                guessSemaphore.signal()
            }

            guessSemaphore.wait()
        }
    }
}
