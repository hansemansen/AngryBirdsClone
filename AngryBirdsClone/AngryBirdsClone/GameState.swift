import Foundation

class GameState: ObservableObject {
    @Published var status: GameStatus = .playing
}
