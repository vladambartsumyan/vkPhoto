//
//  VKPhotoDelegate.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 11.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

import SwiftyVK

enum AuthorizationResult {
    case success
    case fail
}

protocol VKAuthorizationObserver {
    func authorizationCompleted(_ result: AuthorizationResult)
}

class VKPhotoDelegate: VKDelegate {
    
    let appID = "5915863"
    
    private let scope: Set<VK.Scope> = [.photos, .offline, .wall]

    private var observers: [VKAuthorizationObserver] = []
    
    init() {
        VK.config.logToConsole = false
        VK.configure(withAppId: appID, delegate: self)
    }
    
    func addObserver(_ observer: VKAuthorizationObserver) {
        observers.append(observer)
    }
    
    func vkWillAuthorize() -> Set<VK.Scope> {
        return scope
    }
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
        Store.userID = parameters["user_id"]!
        Store.token = parameters["access_token"]!
        observers.forEach { $0.authorizationCompleted(.success) }
    }
    
    func vkAutorizationFailedWith(error: AuthError) {
        // print("Autorization failed with error: \n\(error)")
        observers.forEach { $0.authorizationCompleted(.fail) }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TestVkDidAuthorize"), object: nil)
    }
    
    func vkDidUnauthorize() {
        
    }
    
    func vkShouldUseTokenPath() -> String? {
        return nil
    }
    
    #if os(OSX)
    func vkWillPresentView() -> NSWindow? {
        return NSApplication.shared().windows[0]
    }
    #elseif os(iOS)
    func vkWillPresentView() -> UIViewController {
        return UIApplication.shared.delegate!.window!!.rootViewController!
    }
    #endif
}
