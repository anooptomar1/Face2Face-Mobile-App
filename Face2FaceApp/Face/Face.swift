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
}

