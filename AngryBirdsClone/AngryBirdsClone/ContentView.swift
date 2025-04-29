import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var scene: GameScene
    @StateObject private var gameState = GameState()
    init() {
        let initialGameState = GameState()
        _gameState = StateObject(wrappedValue: initialGameState)
        _scene = State(initialValue: GameScene(size: CGSize(width: 896, height: 414), gameState: initialGameState))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            if gameState.status != .playing {
                VStack {
                    Text(gameState.status == .won ? "🏆 YOU WIN!" : "🐷 YOU LOST!")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    Text("Tap to Restart")
                        .padding()
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    resetGame()
                }
            }
        }
    }

    func resetGame() {
        gameState.status = .playing
        scene.resetGame()
    }
}
