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
    var target_landmarks : Face!
    @IBOutlet weak var vwTargetVideo: UIView!
    @IBOutlet weak var imvResult: UIImageView!
    
    let shapeLayer = CAShapeLayer()
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
        self.targetPlayer.view.frame = vwTargetVideo.bounds
        
        self.addChildViewController(self.targetPlayer)
        self.vwTargetVideo.addSubview(self.targetPlayer.view)
        self.targetPlayer.didMove(toParentViewController: self)
        
        self.targetPlayer.url = target_url
        self.targetPlayer.playbackLoops = true
        self.targetPlayer.playbackLoops = true
        self.targetPlayer.playFromBegining()
        
        shapeLayer.frame = imvResult.bounds
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        
        //Needs to filp coordinate system for Vision
        shapeLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        imvResult.layer.addSublayer(shapeLayer)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func actionRecognize(_ sender: UIButton) {
        target_landmarks = self.targetPlayer.currentLandmarks
        if (target_landmarks != nil) {
            DispatchQueue.main.async {
                self.shapeLayer.sublayers?.removeAll()
            }
            imvResult.image = target_landmarks.imageFrame
            target_landmarks.base_imageSize = imvResult.frame.size
            target_landmarks.normalize()
            self.draw(points: target_landmarks.allPoints)
//            self.draw(points: target_landmarks.faceContour)
//            self.draw(points: target_landmarks.leftEye)
//            self.draw(points: target_landmarks.rightEye)
//            self.draw(points: target_landmarks.leftEyebrow)
//            self.draw(points: target_landmarks.rightEyebrow)
//            self.draw(points: target_landmarks.leftPupil)
//            self.draw(points: target_landmarks.rightPupil)
//            self.draw(points: target_landmarks.medianLine)
//            self.draw(points: target_landmarks.noseCrest)
//            self.draw(points: target_landmarks.nose)
//            self.draw(points: target_landmarks.innerLips)
//            self.draw(points: target_landmarks.outerLips)
            
        }
        print("landmark detection")
    }
    func draw(points: [CGPoint]) {
        
        UIGraphicsBeginImageContext(imvResult.frame.size)
        imvResult.draw(imvResult.bounds)
        let context = UIGraphicsGetCurrentContext();
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.move(to: points[0])
        
        for i in 1..<points.count {
            context?.addLine(to: points[i])
            context?.move(to: points[i])
        }
        
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imvResult.image = img
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
