//
//  Video.swift
//  Face2FaceApp
//
//  Created by mac on 9/15/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Video : NSObject {
    var asset : AVAsset!
    var playerItem : AVPlayerItem!
    var duration : CMTime!
    var fps : Float!
    var resolution : CGSize!
    var imageFrames : [UIImage] = []
    
    init(url : URL) {
        super.init()
        self.asset = AVAsset(url: url)
        self.playerItem = AVPlayerItem(asset: self.asset)
        self.duration = self.asset.duration
        self.fps = self.getFrameRate(item: playerItem)
        self.resolution = self.getVideoResolution(asset: asset)
    }
    func getFrameRate(item : AVPlayerItem) -> Float {
        var fps : Float = 0.0
        guard let track = asset.tracks(withMediaType: .video).first else {return fps}
        fps = track.nominalFrameRate
        
        return fps
    }
    func getVideoResolution(asset : AVAsset) -> CGSize{
        var size = CGSize(width: 0, height: 0)
        guard let track = asset.tracks(withMediaType: .video).first else {return size}
        size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    func getVideoFrame(info : Video) {
        let assetImgGenerator = AVAssetImageGenerator(asset:info.asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        let duration:Float64 = CMTimeGetSeconds(info.duration)
        let durationInt:Int = Int(duration)
        
        for index:Int in 0 ..< durationInt
        {
            generateFrames(
                assetImgGenerate:assetImgGenerator,
                fromTime:Float64(index))
        }
    }
    func generateFrames(
        assetImgGenerate:AVAssetImageGenerator,
        fromTime:Float64)
    {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, 600)
        let cgImage:CGImage?
        
        do
        {
            cgImage = try assetImgGenerate.copyCGImage(at:time, actualTime:nil)
        }
        catch
        {
            cgImage = nil
        }
        
        guard let img:CGImage = cgImage else { return }
        
        let frameImg:UIImage = UIImage(cgImage:img)
        imageFrames.append(frameImg)
    }
}
