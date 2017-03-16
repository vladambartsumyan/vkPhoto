//
//  JSONParser.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 14.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import Foundation
import SwiftyVK
import RealmSwift
class JSONParser {
    
    // Parse album
    static func parseAlbum(_ albumJSON: JSON) -> Album {
        let album = Album()
        album.id = albumJSON["id"].int!
        album.title = albumJSON["title"].string!
        album.size = albumJSON["size"].int!
        album.coverURL = albumJSON["thumb_src"].string!
        return album
    }
    
    // parse photo
    static func parsePhoto(_ photoJSON: JSON) -> Photo {
        let photo = Photo()
        photo.id = photoJSON["id"].int!
        photo.albumID = photoJSON["album_id"].int!
        photo.setPhotoSizes(photoJSON["sizes"].array!.map(parsePhotoSize))
        photo.text = photoJSON["text"].string!
        photo.date = Date.init(timeIntervalSince1970: TimeInterval(photoJSON["date"].int!))
        if let long = photoJSON.dictionary!["long"]?.double {
            photo.longitude = RealmOptional<Double>(long)
            photo.latitude = RealmOptional<Double>(photoJSON["lat"].double)
        }
        return photo
    }
    
    // parse photo size
    static func parsePhotoSize(_ photoSizeJSON: JSON) -> PhotoSize {
        let photoSize = PhotoSize()
        photoSize.url = photoSizeJSON["src"].string!
        photoSize.type = photoSizeJSON["type"].string!
        return photoSize
    }
}
