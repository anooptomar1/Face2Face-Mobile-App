//
//  Face2FaceEngine.swift
//  Face2FaceApp
//
//  Created by mac on 10/16/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import Vision
import UIKit

class Face2FaceEngine: NSObject {
    var sourceLandmark: VNFaceLandmarks2D?
    var targetLandmark: VNFaceLandmarks2D?
    var sourceLandmarkPoints : [CGPoint] = []
    var targetLandmakrPoints : [CGPoint] = []
    
    
    init(source: VNFaceLandmarks2D, target: VNFaceLandmarks2D) {
        sourceLandmark = source
        targetLandmark = target
        if (sourceLandmark?.allPoints) != nil {
            sourceLandmarkPoints = (sourceLandmark?.allPoints?.normalizedPoints)!
        }
        if (targetLandmark?.allPoints) != nil {
            targetLandmakrPoints = (targetLandmark?.allPoints?.normalizedPoints)!
        }
        
    }
    func trackAngle(land_points: [CGPoint]) -> CGFloat{
        var angle : CGFloat = 0
        if land_points.count < 2 {
            return angle
        }
        let p0 = land_points[0]
        let p1 = land_points[1]
        if p0 == p1 {
            return 0
        } else {
            let cosValue = (p1.x - p0.x)/((p1.x - p0.x)*(p1.x - p0.x) + (p1.y - p0.y)*(p1.y - p0.y))
            angle = acos(cosValue)
        }
        
        return angle
    }
}
