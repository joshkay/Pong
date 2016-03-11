//
//  Helpers.swift
//  Pong
//
//  Helper functions for pong.  Contains audio helper functions to load and play
//  sound clips.
//
//  Created by Joshua Kay on 2016-03-11.
//  Copyright © 2016 Josh Kay. All rights reserved.
//
//  Last modified by Josh Kay on 2016-03-11.
//

import Foundation
import AVFoundation

func loadAudio(path: String, ext: String, numLoops: Int = 0) -> AVAudioPlayer
{
    var audioPlayer: AVAudioPlayer
    let url: NSURL = NSBundle.mainBundle().URLForResource(path, withExtension: ext)!
    do
    {
        audioPlayer = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = numLoops
        return audioPlayer
    }
    catch let error as NSError
    {
        print(error.description)
    }
    
    return AVAudioPlayer()
}

func forcePlayAudio(audioPlayer: AVAudioPlayer)
{
    audioPlayer.stop()
    audioPlayer.currentTime = 0
    audioPlayer.play()
}