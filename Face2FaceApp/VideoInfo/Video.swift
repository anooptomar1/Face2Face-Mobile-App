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
        self.getVideoFrame(info: self, fps: self.fps)
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
    func getVideoFrameAsynchronously(info : Video, fps : Float){
        let assetImgGenerator = AVAssetImageGenerator(asset: info.asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        assetImgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        let duration : Float64 = CMTimeGetSeconds(info.duration)
        let durationInt : Int = Int(Float64(fps) * duration)
        
        var timeFrames : [NSValue] = [];
        
        //Generate an array with time frame
        for index:Int in 0 ..< durationInt{
            let timeScale = info.asset.duration.timescale;
            let ftFloat64 = duration * Float64(index) / (Float64(fps) * duration)
            let ftCMTime = CMTime(seconds: ftFloat64, preferredTimescale: timeScale)
            let ftNSValue = NSValue(time: ftCMTime)
            timeFrames.append(ftNSValue)
        }
        assetImgGenerator.generateCGImagesAsynchronously(forTimes: timeFrames) { (rT, imgData, aT, result, error) in
            if error == nil {
                let image = UIImage(cgImage : imgData!)
                self.imageFrames.append(image)
            }
        }
    }
    func getVideoFrame(info : Video, fps : Float) {
        let assetImgGenerator = AVAssetImageGenerator(asset:asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        assetImgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        let dT:Float64 = CMTimeGetSeconds(duration)
        let durationInt:Int = Int(Float64(fps) * dT)
        
        for index:Int in 0 ..< durationInt
        {
            let unitTime : Float64 = dT / Float64(durationInt);
            let startTime : Float64 = unitTime * Float64(index)
            generateFrames(
                assetImgGenerate:assetImgGenerator,
                fromTime:startTime, scale: Int32(durationInt))
        }
    }
    func generateFrames(
        assetImgGenerate:AVAssetImageGenerator,
        fromTime:Float64, scale : Int32)
    {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, scale)
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
    func getVideoFrameByTime(aT: CMTime) -> UIImage {
        let assetImgGenerator = AVAssetImageGenerator(asset:asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        assetImgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        let cgImage:CGImage?
        
        do
        {
            cgImage = try assetImgGenerator.copyCGImage(at:aT, actualTime:nil)
        }
        catch
        {
            cgImage = nil
        }
        
        let img:CGImage = cgImage!
        
        let frameImg:UIImage = UIImage(cgImage:img)
        
        
        return frameImg
    }
}
