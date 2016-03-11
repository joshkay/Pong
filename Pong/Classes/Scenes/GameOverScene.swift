//
//  GameOverScene.swift
//  Pong
//
//  Game over scene for pong.  Displays whether or not the player won/lost.
//  Simple touch will restart the game.
//
//  Created by Joshua Kay on 2016-03-11.
//  Copyright © 2016 Josh Kay. All rights reserved.
//
//  Last modified by Josh Kay on 2016-03-11.
//

import SpriteKit

class GameOverScene : SKScene
{
    var endText: String = ""
    
    override func didMoveToView(view: SKView)
    {
        self.scaleMode = .AspectFill
        
        let gameOverLabel = SKLabelNode(text: "GAME OVER!")
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = UIColor.whiteColor()
        gameOverLabel.position = CGPointMake(self.frame.midX, self.frame.midY + 50)
        
        let endLabel = SKLabelNode(text: endText)
        endLabel.fontSize = 20
        endLabel.horizontalAlignmentMode = .Left
        endLabel.fontColor = UIColor.whiteColor()
        endLabel.position = CGPointMake(self.frame.origin.x + 50, self.frame.origin.y + 50)
        
        let restartNotifyLabel = SKLabelNode(text: "TOUCH TO RESTART")
        restartNotifyLabel.fontSize = 50
        restartNotifyLabel.fontColor = UIColor.whiteColor()
        restartNotifyLabel.position = CGPointMake(self.frame.midX, self.frame.midY - 50)
        
        self.addChild(gameOverLabel)
        self.addChild(endLabel)
        self.addChild(restartNotifyLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        // Load pong when user touches the screen
        let nextScene = PongScene(fileNamed: "PongScene")
        let transition = SKTransition.doorsOpenHorizontalWithDuration(1)
        
        self.view?.presentScene(nextScene!, transition: transition)
    }
}