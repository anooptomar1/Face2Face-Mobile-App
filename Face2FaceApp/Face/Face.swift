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
    var base_imageSize : CGSize!
    
    var allPoints : [CGPoint] = []
    var faceContour : [CGPoint] = []
    var innerLips : [CGPoint] = []
    var outerLips : [CGPoint] = []
    var leftEye : [CGPoint] = []
    var rightEye : [CGPoint] = []
    var nose : [CGPoint] = []
    var leftEyebrow : [CGPoint] = []
    var rightEyebrow : [CGPoint] = []
    var leftPupil : [CGPoint] = []
    var rightPupil : [CGPoint] = []
    var medianLine : [CGPoint] = []
    var noseCrest : [CGPoint] = []
    
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
    func convertPointsForFace(_ landmark: VNFaceLandmarkRegion2D?, imgSize: CGSize?) ->[CGPoint]{        
        let points = landmark?.pointsInImage(imageSize: imgSize!)
        var pos_reverse = [CGPoint]()
        for point in points! {
            let newPos = CGPoint(x: point.x, y: (imgSize?.height)! - point.y)
            pos_reverse.append(newPos)
        }
        return pos_reverse
    }
    func normalize() {
        if let all_points = landmarks.allPoints {
            allPoints = convertPointsForFace(all_points, imgSize: base_imageSize)
        }
        if let fcContour = landmarks.faceContour {
            faceContour = convertPointsForFace(fcContour, imgSize: base_imageSize)
        }
        if let inLips = landmarks.innerLips {
            innerLips = convertPointsForFace(inLips, imgSize: base_imageSize)
        }
        if let outLips = landmarks.outerLips {
            outerLips = convertPointsForFace(outLips, imgSize: base_imageSize)
        }
        if let left_eye = landmarks.leftEye {
            leftEye = convertPointsForFace(left_eye, imgSize: base_imageSize)
        }
        if let right_eye = landmarks.rightEye {
            rightEye = convertPointsForFace(right_eye, imgSize: base_imageSize)
        }
        if let nose_p = landmarks.nose {
            nose = convertPointsForFace(nose_p, imgSize: base_imageSize)
        }
        if let leftEye_brow = landmarks.leftEyebrow {
            leftEyebrow = convertPointsForFace(leftEye_brow, imgSize: base_imageSize)
        }
        if let rightEye_brow = landmarks.rightEyebrow {
            rightEyebrow = convertPointsForFace(rightEye_brow, imgSize: base_imageSize)
        }
        if let leftPupil_p = landmarks.leftPupil {
            leftPupil = convertPointsForFace(leftPupil_p, imgSize: base_imageSize)
        }
        if let rightPupil_p = landmarks.rightPupil {
            rightPupil = convertPointsForFace(rightPupil_p, imgSize: base_imageSize)
        }
        if let median_line = landmarks.medianLine {
            medianLine = convertPointsForFace(median_line, imgSize: base_imageSize)
        }
        if let nose_crest = landmarks.noseCrest {
            noseCrest = convertPointsForFace(nose_crest, imgSize: base_imageSize)
        }
    }
}

