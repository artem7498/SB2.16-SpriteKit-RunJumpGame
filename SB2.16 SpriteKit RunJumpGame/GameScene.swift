//
//  GameScene.swift
//  SB2.16 SpriteKit RunJumpGame
//
//  Created by Артём on 4/11/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let atlas = SKTextureAtlas(named: "assets")
    
    var scoreLabel = SKLabelNode()
    var score: Int = 0{
        didSet{scoreLabel.text = "Score: \(score)"}
    }
    
    var player: SKSpriteNode!
    var ground: SKSpriteNode!
    
    var obstacles: [SKSpriteNode] = []
    var coin: SKSpriteNode!
    
    var cameraNode = SKCameraNode()
    var cameraMovePointsPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    var isTime: CGFloat = 3.0
    
    var onGround: Bool = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var backgroundMusic = SKAudioNode()
    var coinSound = SKAction()
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height{
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        createBG()
        createGround()
        createPlayer()
        setupCamera()
        addScore()
        increaseSpeed()
        
        run(.sequence([
            .wait(forDuration: 3),
            .run { self.spawnBlock() } ]))
        run(.sequence([
            .wait(forDuration: 3),
            .run { self.spawnCoin() } ]))
        
        playBGMusic()
        setupCoinSound()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !isPaused && onGround == true{
            onGround = false
            velocityY = -15.0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if velocityY < -12.5{
            velocityY = -12.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else{
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY{
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
    }
    
    func createBG(){
        for i in 0...2{
            let backgoundTexture = atlas.textureNamed("background")
            let background = SKSpriteNode(texture: backgoundTexture)
            background.name = "Background"
            background.anchorPoint = .zero
            background.position = CGPoint(x: CGFloat(i)*background.frame.width, y: 0.0)
            background.zPosition = -1.0
            addChild(background)
        }
    }
    
    func playBGMusic(){
        backgroundMusic = SKAudioNode(fileNamed: "bgaudio.mp3")
        addChild(backgroundMusic)
        backgroundMusic.run(SKAction.play())
    }
    
    func setupCoinSound(){
        coinSound = SKAction.playSoundFileNamed("coinaudio.mp3", waitForCompletion: false)
    }
    
    func createGround(){
        for i in 0...2{
            let groundTexture = atlas.textureNamed("ground2")
            ground = SKSpriteNode(texture: groundTexture)
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
//            ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
            addChild(ground)
        }

    }
    
    func createPlayer(){
        let playerTexture = atlas.textureNamed("player")
        player = SKSpriteNode(texture: playerTexture)
        player.name = "Player"
        player.zPosition = 5.0
        player.position = CGPoint(x: frame.width/2.0 - 100, y: ground.frame.height + player.frame.height / 2.0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.restitution = 0.0
//        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.obstacle | PhysicsCategory.coin
        
        playerPosY = player.position.y
        addChild(player)
        
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera(){
        let amountToMove = CGPoint(x: cameraMovePointsPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        //Background
        
        enumerateChildNodes(withName: "Background") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x{
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
        
        //Ground
        
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x{
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
    }
    
    func movePlayer(){
        let amountToMove = cameraMovePointsPerSecond * CGFloat(dt)
        player.position.x += amountToMove
    }
    
    func setupObstacles(){
        for i in 1...3{
            let obstaclesTextures = SKTexture(imageNamed: "block-\(i)")
            let sprite = SKSpriteNode(texture: obstaclesTextures)
            sprite.name = "Block"
            obstacles.append(sprite)
        }
        
        for i in 1...3{
            let obstaclesTextures = SKTexture(imageNamed: "fish-\(i)")
            let sprite = SKSpriteNode(texture: obstaclesTextures)
            sprite.name = "Fish"
            obstacles.append(sprite)
        }
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count - 1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.height + sprite.frame.height/2.0)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.isDynamic = false
        
        if sprite.name == "Block"{
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.block
        } else {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        }
        
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        addChild(sprite)
        
        sprite.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        
        ]))
        
    }
    
    func spawnBlock(){
        
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupObstacles()
            }
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),
            .run {
                self.isTime -= 0.1
                
                if self.isTime <= 1.5{
                    self.isTime = 1.5
                }
            }
        ])))
    }
    
    func createCoin(){
        let coinTexture = atlas.textureNamed("coin-1")
        coin = SKSpriteNode(texture: coinTexture)
        coin.name = "Coin"
        coin.zPosition = 20.0
        coin.setScale(0.85)
        coin.size = CGSize(width: coin.size.width/2.0, height: coin.size.height/2.0)
        let coinHeight = coin.frame.height / 2
        let random = CGFloat.random(min: 0, max: coinHeight * 4.0)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width/2, y: size.height/2.0 + random)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(coin)
        coin.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        var textures: [SKTexture] = []
        for i in 1...6{
            textures.append(atlas.textureNamed("coin-\(i)"))
        }
        
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
    }
    func spawnCoin(){
        let random = CGFloat.random(min: 2.5, max: 6.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: TimeInterval(random)),
            .run { [weak self] in
                self?.createCoin()
            }
        ])))
        
    }
    
    func addScore(){
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: -playableRect.width/2.0 + scoreLabel.frame.width, y: playableRect.height/2 - scoreLabel.frame.height * 2)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 60
        score = 0
        
        cameraNode.addChild(scoreLabel)
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                self!.score += 1}
        ])))
    }
    
    func increaseSpeed(){
        run(.repeatForever(.sequence([
            .wait(forDuration: 5),
            .run { self.cameraMovePointsPerSecond += 50}
        ])))
    }
    
    func gameOver(){
        let scene = GameOverScene(size: size)
        scene.score = score
        
        let highScore = ScoreStorage.shared.getHighScore()
        
        if score > highScore{
            ScoreStorage.shared.setHighScore(highscore: score)
        }
        
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(scene, transition: reveal)
    }
        
}

extension GameScene: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.block:
//            cameraMovePointsPerSecond += 150.0
            gameOver()
            print("block contacted")
        case PhysicsCategory.obstacle:
            gameOver()
            print("obstacle contacted")
        case PhysicsCategory.coin:
            run(coinSound)
            if let node = other.node{
                score += 5
                print("Coin")
                node.removeFromParent()
            }
        default:
            break
        }
    }
}
