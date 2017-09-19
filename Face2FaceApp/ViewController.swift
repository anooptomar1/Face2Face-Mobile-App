//
//  ViewController.swift
//  Face2FaceApp
//
//  Created by mac on 9/13/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import ARKit
import Vision

class ViewController: UIViewController {
//    let source_url : URL = Bundle.main.url(forResource: "source", withExtension: "mp4")!
    let target_url : URL = Bundle.main.url(forResource: "target", withExtension: "mp4")!
//    var sourceVideo : Video!
//    var targetVideo : Video!
    fileprivate var targetPlayer = TargetVideoPlayer()
    
    //MARK: Object LifeCycle
    deinit {
        self.targetPlayer.willMove(toParentViewController: self)
        self.targetPlayer.view.removeFromSuperview()
        self.targetPlayer.removeFromParentViewController()
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.targetPlayer.playerDelegate = self
        self.targetPlayer.view.frame = self.view.bounds
        
        self.addChildViewController(self.targetPlayer)
        self.view.addSubview(self.targetPlayer.view)
        self.targetPlayer.didMove(toParentViewController: self)
        
        self.targetPlayer.url = target_url
        self.targetPlayer.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.targetPlayer.view.addGestureRecognizer(tapGestureRecognizer)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.targetPlayer.playFromBegining()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
// MARK: - UIGestureRecognizer

extension ViewController {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch (self.targetPlayer.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            self.targetPlayer.playFromBegining()
            break
        case PlaybackState.paused.rawValue:
            self.targetPlayer.playFromCurrentTime()
            break
        case PlaybackState.playing.rawValue:
            self.targetPlayer.pause()
            break
        case PlaybackState.failed.rawValue:
            self.targetPlayer.pause()
            break
        default:
            self.targetPlayer.pause()
            break
        }
    }
    
}
// MARK: - TargetVideoPlayerDelegate

extension ViewController:TargetVideoPlayerDelegate {
    
    func playerReady(_ player: TargetVideoPlayer) {
    }
    
    func playerPlaybackStateDidChange(_ player: TargetVideoPlayer) {
        
    }
    
    func playerBufferingStateDidChange(_ player: TargetVideoPlayer) {
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
}

// MARK : - PlayerPlaybackDelegate
extension ViewController:PlayerPlaybackDelegate {
    func playerCurrentTimeDidChange(_ player: TargetVideoPlayer) {
        
    }
    
    func playerPlaybackDidEnd(_ player: TargetVideoPlayer) {
        
    }
    
    func playerPlaybackWillLoop(_ player: TargetVideoPlayer) {
        
    }
    
    func playerPlaybackWillStartFromBegining(_ player: TargetVideoPlayer) {
        
    }
    
    
}
