//
//  BlueViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 12.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import ReachabilitySwift

class BlueNavigationController: UINavigationController {

    var isOffline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor.init(red: 80/255, green: 114/255, blue: 153/255, alpha: 1)
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func offlineMode() {
        if !self.isOffline {
            self.isOffline = true
            UIView.transition(with: self.navigationBar, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.navigationBar.barTintColor = UIColor.init(white: 0.5, alpha: 1)
            }, completion: nil)
        }
    }
    
    func onlineMode() {
        if self.isOffline {
            self.isOffline = false
            UIView.transition(with: self.navigationBar, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.navigationBar.barTintColor = UIColor.init(red: 80/255, green: 114/255, blue: 153/255, alpha: 1)
            }, completion: nil)
        }
    }
}
