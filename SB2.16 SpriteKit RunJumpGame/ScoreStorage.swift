//
//  ScoreStorage.swift
//  SB2.16 SpriteKit RunJumpGame
//
//  Created by Артём on 4/13/21.
//

import Foundation

class ScoreStorage{
    
    static let shared = ScoreStorage()
    private init() {}
    
    static let keyHighscore = "keyHighscore"
    static let keyScore = "keyScore"
    
    func setScore(score: Int){
        UserDefaults.standard.set(score, forKey: ScoreStorage.keyScore)
    }
    
    func getScore() -> Int{
        return UserDefaults.standard.integer(forKey: ScoreStorage.keyScore)
    }
    
    func setHighScore(highscore: Int){
        UserDefaults.standard.set(highscore, forKey: ScoreStorage.keyHighscore)
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreStorage.keyHighscore)
    }
    
    
}
