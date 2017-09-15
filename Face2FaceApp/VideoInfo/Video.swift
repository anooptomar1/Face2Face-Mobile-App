//
//  Video.swift
//  Face2FaceApp
//
//  Created by mac on 9/15/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import AVFoundation

class Video : NSObject {
    var asset : AVAsset!
    var playerItem : AVPlayerItem!
    var duration : CMTime!
    var fps : Float!
    var resolution : CGSize!
    
    
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
        for track in item.tracks {
            if track.assetTrack.mediaType == .video {
                fps = track.currentVideoFrameRate
            }
        }
        
        return fps
    }
    func getVideoResolution(asset : AVAsset) -> CGSize{
        var size = CGSize(width: 0, height: 0)
        guard let track = asset.tracks(withMediaType: .video).first else {return size}
        size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}
