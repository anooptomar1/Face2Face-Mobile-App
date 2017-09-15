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

class ViewController: UIViewController {
    let source_url : URL = Bundle.main.url(forResource: "source", withExtension: "mp4")!
    let target_url : URL = Bundle.main.url(forResource: "target", withExtension: "mp4")!
    var sourceVideo : Video!
    var targetVideo : Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceVideo = Video(url: self.source_url)
        targetVideo = Video(url: self.target_url)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

