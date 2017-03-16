//
//  Album.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 12.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import Foundation
import RealmSwift

class Album: Object {
    dynamic var id: Int = 0
    dynamic var title: String = ""
    dynamic var size: Int = 0
    dynamic var coverURL: String = ""
    
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
