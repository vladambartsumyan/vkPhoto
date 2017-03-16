//
//  SadCloudViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 16.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit

class SadCloudViewController: UIViewController {

    @IBOutlet weak var cloud: UIImageView!
    
    @IBOutlet weak var massage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setBlackCloud() {
        cloud.image = #imageLiteral(resourceName: "sad_black.png")
    }
    
    func setWhiteCloud() {
        cloud.image = #imageLiteral(resourceName: "sad.png")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
