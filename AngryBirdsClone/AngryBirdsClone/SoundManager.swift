//
//  SoundManager.swift
//  BallTest4
//
//  Created by Swift Copilot on 26/04/2025.
//

import Foundation
import AVFoundation

class SoundManager {
    
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    private(set) var isMuted = false
    
    private init() {}
    
    func preloadSounds(filenames: [String]) {
        for filename in filenames {
            preloadSound(named: filename)
        }
    }
    
    private func preloadSound(named filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("❗ Kunne ikke finde lydfilen: \(filename)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[filename] = player
            print("🔊 Preloadet: \(filename)")
        } catch {
            print("❗ Kunne ikke loade \(filename): \(error.localizedDescription)")
        }
    }
    
    func playSound(named filename: String) {
        guard !isMuted else { return }
        
        if let player = players[filename] {
            player.currentTime = 0
            player.play()
        } else {
            print("❗ Lyden '\(filename)' er ikke preloadet!")
        }
    }
    
    func mute() {
        isMuted = true
        players.values.forEach { $0.stop() }
    }
    
    func unmute() {
        isMuted = false
    }
}
