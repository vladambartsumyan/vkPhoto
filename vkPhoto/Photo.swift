//
//  Photo.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 12.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoSize {
    var url: String = ""
    var type: String = ""
}

class Photo: Object {
    dynamic var id: Int = 0
    dynamic var albumID: Int = 0
    dynamic var smallPhoto: String = ""
    dynamic var bigPhoto: String = ""
    dynamic var text: String = ""
    var latitude = RealmOptional<Double>()
    var longitude = RealmOptional<Double>()
    dynamic var date: Date = Date()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func setPhotoSizes(_ photoSizes: [PhotoSize]) {
        // Types of uncircumcised photo which sorted by size
        let typeSize = ["s" : 0, "m" : 1, "x" : 2, "y" : 3, "z" : 4, "w" : 5]
        
        var smallPhotoType = "w"
        var bigPhotoType = "s"
        
        photoSizes.forEach {
            if let ts = typeSize[$0.type] {
                if ts <= typeSize[smallPhotoType]! {
                    smallPhotoType = $0.type
                    smallPhoto = $0.url
                }
                if ts >= typeSize[bigPhotoType]! {
                    bigPhotoType = $0.type
                    bigPhoto = $0.url
                }
            }
        }
    }
    
    
}
