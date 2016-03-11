//
//  PongController.swift
//  Pong
//
//  Pong controller helper class.  Keeps track of scores and whether or not the game
//  is over.
//
//  Created by Joshua Kay on 2016-03-11.
//  Copyright © 2016 Josh Kay. All rights reserved.
//
//  Last modified by Josh Kay on 2016-03-11.
//

import SpriteKit

class PongController
{
    var playerScore = 0
    var oponentScore = 0
    
    func playerScoreAdd()
    {
        playerScore++
    }
    
    func oponentScoreAdd()
    {
        oponentScore++
    }
    
    func isGameOver() -> Bool
    {
        return (oponentScore == 3) || (playerScore == 3)
    }
    
    func didPlayerWin() -> Bool
    {
        return (playerScore == 3)
    }
}