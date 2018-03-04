//
//  ViewController.swift
//  face_detection
//
//  Created by Soubhi Hadri on 3/3/18.
//  Copyright © 2018 hadri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FrameExtractorDelegate {
    @IBOutlet var imageview: UIImageView!
    var frameExtractor: FrameExtractor!

    
    func captured(image: UIImage) {
        imageview.image = OpencvWrapper.detect(image);
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func flip_camera(_ sender: UIButton) {
        frameExtractor.flipCamera()
    }
    
}

