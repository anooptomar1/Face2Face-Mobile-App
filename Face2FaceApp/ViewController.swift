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
    var source_landmarks : Face!
    @IBOutlet weak var vwTargetVideo: UIView!
    @IBOutlet weak var vwSource: UIView!
    @IBOutlet weak var imvTargetResult: UIImageView!
    @IBOutlet weak var imvSourceResult: UIImageView!
    
    let shapeLayer = CAShapeLayer()
    //MARK: Object LifeCycle
    deinit {
        self.targetPlayer.willMove(toParentViewController: self)
        self.targetPlayer.view.removeFromSuperview()
        self.targetPlayer.removeFromParentViewController()
    }
    
    //MARK: AVCaptureVideoPreviewLayer for live facial tracking(Source Video).
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        guard let session = self.session else { return nil }
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }()
    
    //MARK: Camera device for live facial tracking(Source Video).
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
        
        shapeLayer.frame = imvTargetResult.bounds
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        
        //Needs to filp coordinate system for Vision
        shapeLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        imvTargetResult.layer.addSublayer(shapeLayer)
        
        sessionPrepare()
        guard let previewLayer = previewLayer else { return }
        
        vwSource.layer.addSublayer(previewLayer)
        session?.startRunning()
        
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
            source_landmarks.base_imageSize = imvSourceResult.frame.size
            source_landmarks.normalize()
            self.draw(points: source_landmarks.allPoints, imv: imvSourceResult)
//            imvResult.image = target_landmarks.imageFrame
            target_landmarks.base_imageSize = imvTargetResult.frame.size
            target_landmarks.normalize()
            self.draw(points: target_landmarks.allPoints, imv: imvTargetResult)
//            self.draw(points: target_landmarks.allPoints, imv: )
        }
        print("landmark detection")
    }
    func draw(points: [CGPoint], imv: UIImageView) {
        
        UIGraphicsBeginImageContext(imv.frame.size)
        imv.draw(imv.bounds)
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
        
        imv.image = img
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
        source_landmarks = targetPlayer.detectLandmarksByImage(on: ciImageWithOrientation)
        
        target_landmarks = self.targetPlayer.currentLandmarks
        if (source_landmarks != nil && target_landmarks != nil) {
            DispatchQueue.main.async {
                self.shapeLayer.sublayers?.removeAll()
            }
            imvTargetResult.image = target_landmarks.imageFrame
            target_landmarks.base_imageSize = imvTargetResult.frame.size
            target_landmarks.normalize()
            self.draw(points: target_landmarks.allPoints, imv: imvTargetResult)
        }
        
        
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
