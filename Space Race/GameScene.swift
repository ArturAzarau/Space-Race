//
//  GameScene.swift
//  Space Race
//
//  Created by Артур Азаров on 12.08.2018.
//  Copyright © 2018 Артур Азаров. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    private var starfield: SKEmitterNode!
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    private var possibleEnemies = ["ball", "hammer", "tv"]
    private var gameTimer: Timer!
    private var isGameOver = false
    
    // MARK: - Scene life cycle
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        createBackground()
        createPlayer()
        createScoreLabel()
        configurePhysicsWorld()
        setUpEnemiesCreationTimer()
    }
    
    // MARK: - Handling touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    // MARK: - Methods
    private func createBackground() {
        let starfield = SKEmitterNode(fileNamed: "Starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
    }
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
    }
    
    private func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 90, y: 16)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
    
    private func configurePhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    private func setUpEnemiesCreationTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemies), userInfo: nil, repeats: true)
    }
    
    @objc private func createEnemies() {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736)
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.collisionBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.angularVelocity = 5
    }
    
    // MARK: - Updating game
    
    override func update(_ currentTime: TimeInterval) {
        children.filter({ $0.position.x < -300}).forEach { $0.removeFromParent() }
        if !isGameOver { score += 1 }
    }
    
    
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        isGameOver = true
    }
}
