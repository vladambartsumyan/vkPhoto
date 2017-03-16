//
//  LiveViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 15.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import ReachabilitySwift

class LiveViewController: UIViewController {
    
    let reachability = Reachability()!
    
    static var online = true
    
    static var errorWasPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if InternetConnectionChecker.check() {
            onlineMode()
        } else {
            offlineMode(shouldShowError: false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
        
        reachability.whenReachable = { _ in
            self.onlineMode()
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
        
        reachability.whenUnreachable = { _ in
            self.offlineMode(shouldShowError: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability.stopNotifier()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    var isAnimating = false
    
    func showConnectionError() {
        guard !isAnimating else { return }
        isAnimating = true
        let height: CGFloat = 20.0
        let offlineLabel = UILabel()
        offlineLabel.text = "Нет доступа к сети"
        offlineLabel.font = UIFont.boldSystemFont(ofSize: 10)
        offlineLabel.frame = CGRect(x: 0, y: -height, width: self.view.frame.width, height: height)
        offlineLabel.backgroundColor = UIColor.init(white: 0.85, alpha: 0.6)
        offlineLabel.textColor = UIColor.init(red: 140/255, green: 25/255, blue: 25/255, alpha: 1)
        offlineLabel.textAlignment = .center
        self.view.addSubview(offlineLabel)
        UIView.animate(withDuration: 0.5, animations: {
            offlineLabel.frame.origin.y = 0
        }, completion: { completed in
            UIView.animate(withDuration: 0.5, delay: 2, animations: {
                offlineLabel.frame.origin.y = -height
            }, completion: { completed in
                offlineLabel.removeFromSuperview()
                self.isAnimating = false
            })
        })
    }
    
    func showConnectionErrorWithAlert() {
        let alert = UIAlertController.init(title: nil, message: "Нет доступа к сети", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func offlineMode(shouldShowError: Bool) {
        DispatchQueue.main.async {
            if LiveViewController.online || shouldShowError {
                LiveViewController.online = false
                self.showConnectionError()
            }
            (self.navigationController as? BlueNavigationController)?.offlineMode()
        }
    }
    
    func onlineMode() {
        DispatchQueue.main.async {
            LiveViewController.online = true
            (self.navigationController as? BlueNavigationController)?.onlineMode()
            LiveViewController.errorWasPresented = false
        }
    }
    
    func startLoadIndication() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopLoadIndication() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func reloadData() {}
}
