import Foundation

class APIService {
    static let baseURL = "https://mastermind.darkube.app"

    static func createGame(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "powershell.exe")
            process.arguments = [
                "-Command",
                "Invoke-RestMethod -Uri '\(baseURL)/game' -Method POST -ContentType 'application/json' -Body '{}' | ConvertTo-Json"
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Real API Response: \(responseString)")
                    
                    if let data = responseString.data(using: .utf8) {
                        do {
                            let response = try JSONDecoder().decode(CreateGameResponse.self, from: data)
                            DispatchQueue.main.async {
                                print("Real game created: \(response.game_id)")
                                completion(response.game_id)
                            }
                            return
                        } catch {
                            print("Failed to decode real API response: \(error)")
                        }
                    }
                }
            } catch {
                print("Failed to execute PowerShell: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    static func sendGuess(gameID: String, guess: String, completion: @escaping (GuessResponse?) -> Void) {
        DispatchQueue.global().async {
            let requestBody = """
            {
                "game_id": "\(gameID)",
                "guess": "\(guess)"
            }
            """
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "powershell.exe")
            process.arguments = [
                "-Command",
                "Invoke-RestMethod -Uri '\(baseURL)/guess' -Method POST -ContentType 'application/json' -Body '\(requestBody)' | ConvertTo-Json"
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Real API Response: \(responseString)")
                    
                    if let data = responseString.data(using: .utf8) {
                        do {
                            let result = try JSONDecoder().decode(GuessResponse.self, from: data)
                            DispatchQueue.main.async {
                                print("Real guess response: \(result.black) black, \(result.white) white")
                                completion(result)
                            }
                            return
                        } catch {
                            print("Failed to decode real API response: \(error)")
                        }
                    }
                }
            } catch {
                print("Failed to execute PowerShell: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}
