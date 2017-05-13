//
//  ViewController.swift
//  MPics
//
//  Created by Moin Pansare on 05/05/2017.
//  Copyright (c) 2017 Moin Pansare. All rights reserved.
//

import UIKit
import MPics

class ViewController: UIViewController,MPicsProtocol {

    var myController : MPics = MPics();
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadCameraButtonCLicked(_ sender: Any) {
        myController.loadMPics(source : MPicsSource.camera, parent: self)
    }
    
    func singleImageSnappedFromCamers(image: UIImage) {
        self.imageView.image = image;
        self.imageView.clipsToBounds = true;
        self.imageView.layer.shadowRadius = 5;
        self.imageView.layer.cornerRadius = 5;
        self.imageView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0);
        self.imageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    override var prefersStatusBarHidden: Bool {
        return true;
    }
}

