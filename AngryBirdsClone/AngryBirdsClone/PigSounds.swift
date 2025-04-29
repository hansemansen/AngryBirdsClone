// PigSoundManager.swift

import SpriteKit
import AVFoundation

class PigSounds {
    private var pigGryntTimer: Timer?
    private let gryntSounds = ["grynt1.wav", "grynt2.wav", "grynt3.wav"]

    func startPigGryntTimer() {
        pigGryntTimer?.invalidate()
        
        let randomInterval = Double.random(in: 2.0...4.0)
        
        pigGryntTimer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { [weak self] _ in
            self?.playRandomPigGrynt()
            self?.startPigGryntTimer()
        }
    }

    private func playRandomPigGrynt() {
        if let randomGrynt = gryntSounds.randomElement() {
            SoundManager.shared.playSound(named: randomGrynt)
        }
    }
}
