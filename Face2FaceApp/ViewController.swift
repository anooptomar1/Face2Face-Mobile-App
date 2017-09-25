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
import AVFoundation

class ViewController: UIViewController {
    let target_url : URL = Bundle.main.url(forResource: "target", withExtension: "mp4")!
    var session: AVCaptureSession?
    
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
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        guard let session = self.session else { return nil }
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }()
    var frontCamera: AVCaptureDevice? = {
        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }()
    
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
    func sessionPrepare() {
        session = AVCaptureSession()
        guard let session = session, let captureDevice = frontCamera else { return }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            
            output.alwaysDiscardsLateVideoFrames = true
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self, queue: queue)
            print("setup delegate")
        } catch {
            print("can't setup session")
        }
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
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
        
        //leftMirrored for front camera
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImageOrientation.leftMirrored.rawValue))
        
//        detectFace(on: ciImageWithOrientation)
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
