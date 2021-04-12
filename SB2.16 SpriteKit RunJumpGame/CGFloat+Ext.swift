//
//  CGFloat+Ext.swift
//  SB2.16 SpriteKit RunJumpGame
//
//  Created by Артём on 4/12/21.
//

import CoreGraphics

extension CGFloat{
    
    
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF)) // return 0,1
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        assert(min < max)
        return CGFloat.random() * (max - min) + min // return min or max
    }


}
