//
//  CGRect+Scaled.swift
//  Face2FaceApp
//
//  Created by mac on 9/21/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}
