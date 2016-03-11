//
//  PongScene.swift
//  Pong
//
//  Scene for pong game. Handles all gameplay logic, addition/removal of sprites
//  along with physics.  The main class for the game.
//
//  Created by Joshua Kay on 2016-03-11.
//  Copyright (c) 2016 Josh Kay. All rights reserved.
//
//  Last modified by Josh Kay on 2016-03-11.
//

import SpriteKit
import AVFoundation

class PongScene : SKScene, SKPhysicsContactDelegate
{
    // Sprite objects
    var paddle1: SKSpriteNode?
    var paddle2: SKSpriteNode?
    var ball: SKShapeNode?
    
    var playersFieldEnd: SKSpriteNode?
    var opponentFieldEnd: SKSpriteNode?
    
    var playerScore: SKLabelNode?
    var opponentScore: SKLabelNode?
    
    var difficulty: SKLabelNode?
    
    var waitingToStart = true
    var reset = false
    let pongController = PongController()
    
    enum AIDifficulty
    {
        case EASY
        case MEDIUM
        case HARD
    }
    var opponentDifficulty: AIDifficulty = .EASY
    
    // Initial impulse to ball
    let initialImpulse: CGVector = CGVector(dx: 5, dy: 5)
    
    // Audio players
    var paddleHitAudio = AVAudioPlayer()
    var playerScoreAudio = AVAudioPlayer()
    var opponentScoreAudio = AVAudioPlayer()
    var winAudio = AVAudioPlayer()
    var loseAudio = AVAudioPlayer()
    var ambientAudio = AVAudioPlayer()
    
    // Collision categories
    let ballCategory: UInt32 = 0x1 << 0
    let paddleCategory: UInt32 = 0x1 << 1
    let playerScoreCategory: UInt32 = 0x1 << 2
    let opponentScoreCateogry: UInt32 = 0x1 << 3
    
    override func didMoveToView(view: SKView)
    {
        // Create paddles
        self.paddle1 = createPaddle(100, width: 30, position: CGPointMake(10 + 15 ,self.frame.midY))
        self.paddle2 = createPaddle(100, width: 30, position: CGPointMake(self.frame.maxX-(10+15), self.frame.midY))
       
        // Create ball
        self.ball = createBall(20, position: CGPoint(x: self.frame.midX, y: self.frame.midY))
        
        // Create ends for scoring
        self.playersFieldEnd = createBoundary(true)
        self.opponentFieldEnd = createBoundary(false)
        
        // Create score indicators
        self.playerScore = createPointsLabel(true)
        self.opponentScore = createPointsLabel(false)
        
        self.difficulty = createDifficultyLabel()
        
        self.addChild(paddle1!)
        self.addChild(paddle2!)
        self.addChild(ball!)
        self.addChild(playersFieldEnd!)
        self.addChild(opponentFieldEnd!)
        
        self.addChild(playerScore!)
        self.addChild(opponentScore!)
        
        self.addChild(difficulty!)
        
        // Setup boundaries
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.friction = 0
        
        // Setup physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        // Setup audio players
        paddleHitAudio = loadAudio("PaddleHit", ext: "mp3")
        playerScoreAudio = loadAudio("WinPoint", ext: "mp3")
        opponentScoreAudio = loadAudio("LosePoint", ext: "mp3")
        
        winAudio = loadAudio("Win", ext: "mp3")
        loseAudio = loadAudio("Lose", ext: "mp3")
        ambientAudio = loadAudio("AmbientMusic", ext: "wav", numLoops: -1)
        
        ambientAudio.volume = 0.1
        ambientAudio.play()
    }
    
    // Create a label to display points
    func createPointsLabel(isPlayer: Bool) -> SKLabelNode
    {
        let label = SKLabelNode(text: "0")
        
        if (isPlayer)
        {
            label.position = CGPointMake(self.frame.midX / 2, self.frame.midY)
        }
        else
        {
            label.position = CGPointMake(self.frame.midX + self.frame.midX / 2, self.frame.midY)
        }
        
        label.fontColor = UIColor.whiteColor()
        label.fontSize = 100
        
        return label
    }
    
    // Create a label to display difficulty
    func createDifficultyLabel() -> SKLabelNode
    {
        let label = SKLabelNode(text: getOpponentDifficulty())

        label.position = CGPointMake(self.frame.width - 20, self.frame.height - 20)
        
        label.fontColor = UIColor.whiteColor()
        label.fontSize = 20
        label.horizontalAlignmentMode = .Right
        return label
    }
    
    // Create a ball for pong
    func createBall(radius: CGFloat, position: CGPoint) -> SKShapeNode
    {
        let b = SKShapeNode(circleOfRadius: radius)
        b.fillColor = UIColor.blueColor()
        b.strokeColor = UIColor.blueColor()
        b.position = position
        
        b.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        
        b.physicsBody?.categoryBitMask = ballCategory
        b.physicsBody?.collisionBitMask = ballCategory | paddleCategory | playerScoreCategory | opponentScoreCateogry
        b.physicsBody?.contactTestBitMask = ballCategory | paddleCategory | playerScoreCategory | opponentScoreCateogry

        b.physicsBody?.friction = 0
        b.physicsBody?.linearDamping = 0
        b.physicsBody?.restitution = 1
        b.physicsBody?.mass = 0.01
        b.physicsBody?.allowsRotation = false
        
        return b
    }
    
    func createBoundary(isPlayerBoundary: Bool) -> SKSpriteNode
    {
        let width: CGFloat = 5
        let height: CGFloat = self.frame.height
        
        let boundary = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: width, height: height))
        
        boundary.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: width, height: height))
        boundary.physicsBody?.dynamic = false
        
        if (isPlayerBoundary)
        {
            boundary.color = UIColor.redColor()
            boundary.position = CGPointMake(self.frame.minX + width / 2, self.frame.midY)
            boundary.physicsBody?.categoryBitMask = playerScoreCategory
        }
        else
        {
            boundary.color = UIColor.greenColor()
            boundary.position = CGPointMake(self.frame.maxX - width / 2, self.frame.midY)
            boundary.physicsBody?.categoryBitMask = opponentScoreCateogry
        }
        
        return boundary
    }
    
    func createPaddle(height: CGFloat, width: CGFloat, position: CGPoint) -> SKSpriteNode
    {
        let paddle = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: width, height: height))
        
        paddle.position = position
        
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: width, height: height))
        
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        paddle.physicsBody?.friction = 1
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.dynamic = false
        
        return paddle
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        if (contact.bodyB.categoryBitMask == ballCategory) && (contact.bodyA.categoryBitMask == playerScoreCategory)
        {
            // Score a point for the opponent
            pongController.oponentScoreAdd()
            opponentScore?.text = String(pongController.oponentScore)
            
            forcePlayAudio(opponentScoreAudio)
            
            reset = true
        }
        else if (contact.bodyB.categoryBitMask == ballCategory) && (contact.bodyA.categoryBitMask == opponentScoreCateogry)
        {
            // Score a point for the player
            pongController.playerScoreAdd()
            playerScore?.text = String(pongController.playerScore)
            
            playerScoreAudio.play()
            increaseDifficulty()
            
            reset = true
        }
        else if (contact.bodyB.categoryBitMask == ballCategory) && (contact.bodyA.categoryBitMask == paddleCategory)
        {
            // Paddle hit
            forcePlayAudio(paddleHitAudio)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        /* Called when a touch begins */
        
        if (waitingToStart)
        {
            waitingToStart = false
            ball?.physicsBody?.applyImpulse(initialImpulse)
        }
        
        if let touch = touches.first
        {
            let pos = touch.locationInNode(self)
            let actionMove = SKAction.moveToY(pos.y, duration: 0.1)
            
            paddle1?.runAction(actionMove)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first
        {
            let pos = touch.locationInNode(self)
            let actionMove = SKAction.moveToY(pos.y, duration: 0.1)
            
            paddle1?.runAction(actionMove)
        }
    }
    
    func resetBall()
    {
        waitingToStart = true
        reset = false
        
        ball?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    }
    
    func increaseDifficulty()
    {
        switch (opponentDifficulty)
        {
        case .EASY:
            opponentDifficulty = .MEDIUM
        default:
            opponentDifficulty = .HARD
        }
        
        difficulty!.text = getOpponentDifficulty()
    }
    
    func getOpponentDifficulty() -> String
    {
        switch (opponentDifficulty)
        {
        case .EASY:
            return "EASY"
        case .MEDIUM:
            return "MEDIUM"
        default:
            return "HARD"
        }
    }
    
    func getOpponentSpeed() -> NSTimeInterval
    {
        switch (opponentDifficulty)
        {
        case .EASY:
            return 0.4
        case .MEDIUM:
            return 0.25
        default:
            return 0.1
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        if (!pongController.isGameOver())
        {
            if (reset)
            {
                resetBall()
            }
            
            let moveAction = SKAction.moveToY((ball?.position.y)!, duration: getOpponentSpeed())
            paddle2?.runAction(moveAction)
        }
        else
        {
            // Game is over!
            let gameOverScene = GameOverScene(fileNamed: "GameOverScene")

            if (pongController.didPlayerWin())
            {
                gameOverScene?.endText = "WINNER"
                forcePlayAudio(winAudio)
            }
            else
            {
                gameOverScene?.endText = "LOSER"
                forcePlayAudio(loseAudio)
            }

            self.view?.presentScene(gameOverScene!, transition: SKTransition.flipHorizontalWithDuration(2))
        }
    }
}