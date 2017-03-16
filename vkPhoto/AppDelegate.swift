//
//  AppDelegate.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 11.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import SwiftyVK
import RealmSwift
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var vkdelegate: VKPhotoDelegate!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        GMSServices.provideAPIKey("AIzaSyDW_oGulWc4eUL4VdMLTlHgEYbYIgOE6sY")
        
        vkdelegate = VKPhotoDelegate.init()
        VK.configure(withAppId: vkdelegate.appID, delegate: vkdelegate)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        if VK.state == .authorized {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "blueNavigationController")
        } else {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "authorization")
        }
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let app = options[.sourceApplication] as? String
        VK.process(url: url, sourceApplication: app)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VK.process(url: url, sourceApplication: sourceApplication)
        return true
    }
    
}

