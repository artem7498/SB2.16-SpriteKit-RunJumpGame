//
//  GameViewController.swift
//  SB2.16 SpriteKit RunJumpGame
//
//  Created by Артём on 4/11/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
//        skView.showsPhysics = true
        skView.presentScene(scene)
        
    }
}
