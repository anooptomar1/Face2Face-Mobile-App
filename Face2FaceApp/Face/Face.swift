//
//  Face.swift
//  Face2FaceApp
//
//  Created by mac on 9/19/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import Vision
import UIKit

class Face: NSObject {
    var landmarks : VNFaceLandmarks2D!
    var facepose : CGAffineTransform!
    var imageFrame : UIImage!
    var base_boundingbox : CGRect!
    
    
    init(frame: UIImage, observation: VNFaceObservation) {
        super.init()
        self.imageFrame = frame
        self.landmarks = observation.landmarks
        self.facepose = CGAffineTransform.identity
        self.base_boundingbox = observation.boundingBox
        
    }
    func convert(_ points: UnsafePointer<vector_float2>, with count: Int) -> [(x: CGFloat, y: CGFloat)] {
        var convertedPoints = [(x: CGFloat, y: CGFloat)]()
        for i in 0...count {
            convertedPoints.append((CGFloat(points[i].x), CGFloat(points[i].y)))
        }
        return convertedPoints
    }
}

