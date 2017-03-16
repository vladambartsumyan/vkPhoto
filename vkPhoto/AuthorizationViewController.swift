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

class AuthorizationViewController: UIViewController, VKAuthorizationObserver, UIAlertViewDelegate {

    @IBOutlet weak var buttonToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    var needAnimation = true
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).vkdelegate.addObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if needAnimation {
            self.logo.frame.origin.y = UIScreen.main.bounds.height / 2 - self.logo.frame.width / 2
            self.button.frame.origin.y += buttonToBottom.constant + self.button.frame.height
            UIView.animate(withDuration: 1, delay: 0.5, animations: {
                self.logo.frame.origin.y = 50
                self.button.frame.origin.y -= self.buttonToBottom.constant + self.button.frame.height
            }, completion: nil)
        }
    }
    
    func authorizationCompleted(_ result: AuthorizationResult) {
        if result == .success {
            DispatchQueue.main.async {
                self.perform(#selector(self.performLoginSegue), with: nil, afterDelay: 1)
            }
        } else {
            stopLoading()
        }
    }
    
    func performLoginSegue() {
        self.performSegue(withIdentifier: "login", sender: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func vkLoginTouch(_ sender: UIButton) {
        startLoading()
        if reachability.isReachable {
            VK.logIn()
        } else {
            stopLoading()
            presentErrorAlert()
        }
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.button.setTitle("", for: .normal)
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.button.setTitle("Войти через ВКонтакте", for: .normal)
        }
    }
    
    func presentErrorAlert() {
        let alert = UIAlertController.init(title: nil, message: "Отсутствует подключение к интернету", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

