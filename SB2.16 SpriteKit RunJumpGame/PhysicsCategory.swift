//
//  PhysicsCategory.swift
//  SB2.16 SpriteKit RunJumpGame
//
//  Created by Артём on 4/13/21.
//

import Foundation

struct PhysicsCategory {
    static let player: UInt32 = 0b1 //1
    static let block: UInt32 = 0b10 //2
    static let obstacle: UInt32 = 0b100 //4
    static let ground: UInt32 = 0b1000 //8
    static let coin: UInt32 = 0b10000 //16
    
}
