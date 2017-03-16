//
//  ViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 11.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import SwiftyVK
import RealmSwift

class AuthorizationViewController: LiveViewController, VKAuthorizationObserver, UIAlertViewDelegate {

    @IBOutlet weak var buttonToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    var needAnimation = true
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).vkdelegate.addObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needAnimation {
            self.logo.frame.origin.y = UIScreen.main.bounds.height / 2 - self.logo.frame.width / 2
            self.button.frame.origin.y += buttonToBottom.constant + self.button.frame.height
            UIView.animate(withDuration: 1, delay: 0.5, animations: {
                self.logo.frame.origin.y = 50
                self.button.frame.origin.y -= self.buttonToBottom.constant + self.button.frame.height
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func authorizationCompleted(_ result: AuthorizationResult) {
        if result == .success {
            DispatchQueue.main.async {
                self.perform(#selector(self.performLoginSegue), with: nil, afterDelay: 1)
            }
        } else {
            stopLoadIndication()
        }
    }
    
    func performLoginSegue() {
        self.performSegue(withIdentifier: "login", sender: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func vkLoginTouch(_ sender: UIButton) {
        startLoadIndication()
        if InternetConnectionChecker.check() {
            VK.logIn()
        } else {
            stopLoadIndication()
            showConnectionErrorWithAlert()
        }
    }
    
    override func startLoadIndication() {
        super.startLoadIndication()
        self.button.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.button.setTitle("", for: .normal)
            self.activityIndicator.startAnimating()
        }
    }
    
    override func stopLoadIndication() {
        super.stopLoadIndication()
        self.button.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.button.setTitle("Войти через ВКонтакте", for: .normal)
        }
    }
}

