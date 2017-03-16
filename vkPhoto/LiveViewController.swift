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
    
    var reachability = Reachability()!
    
    static var errorWasPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configReachability()
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try reachability.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability.stopNotifier()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configReachability() {
        reachability.whenReachable = { reachability in
            self.onlineMode()
        }
        
        reachability.whenUnreachable = { reachability in
            self.offlineMode()
            self.showConnectionError()
            LiveViewController.errorWasPresented = true
        }
    }
    
    var animatenow = false
    var offlineLabel: UILabel!
    
    func showConnectionError() {
        guard !animatenow else { return }
        LiveViewController.errorWasPresented = true
        animatenow = true
        let height: CGFloat = 20.0
        offlineLabel = UILabel()
        offlineLabel.text = "Нет доступа к сети"
        offlineLabel.font = UIFont.boldSystemFont(ofSize: 10)
        offlineLabel.frame = CGRect(x: 0, y: -height, width: self.view.frame.width, height: height)
        offlineLabel.backgroundColor = UIColor.init(white: 0.85, alpha: 0.6)
        offlineLabel.textColor = UIColor.init(red: 180/255, green: 64/255, blue: 35/255, alpha: 1)
        offlineLabel.textAlignment = .center
        DispatchQueue.main.async {
            self.view.addSubview(self.offlineLabel)
            UIView.animate(withDuration: 0.5, animations: {
                self.offlineLabel.frame.origin.y = 0
            }, completion: { completed in
                UIView.animate(withDuration: 0.5, delay: 2, animations: {
                    self.offlineLabel.frame.origin.y = -height
                }, completion: { completed in
                    self.offlineLabel.removeFromSuperview()
                    self.animatenow = false
                })
            })
        }
    }
    
    func offlineMode() {
        (self.navigationController as? BlueNavigationController)?.offlineMode()
    }
    
    func onlineMode() {
        (self.navigationController as? BlueNavigationController)?.onlineMode()
        LiveViewController.errorWasPresented = false
    }
    
    func startLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
