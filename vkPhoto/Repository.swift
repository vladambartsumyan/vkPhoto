//
//  Repository.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 13.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import Foundation
import SwiftyVK
import RealmSwift

enum Source {
    case server
    case database
}

class Repository {
    
    // Fetchs all albums from vk
    func fetchAlbums(handler: @escaping ([Album], Error?) -> Void) {
        VK.API.Photos.getAlbums([
            // VK.Arg.ownerId : Store.userID!,
            VK.Arg.needCovers : "1",
            VK.Arg.needSystem : "1"
            ])
            .send(
                onSuccess: { response in
                    let albums = response["items"].array!.map(JSONParser.parseAlbum)
                    self.saveAlbums(albums: albums)
                    handler(albums, nil)
            },
                onError: { error in
                    handler([], error)
            })
    }
    
    // Gets all albums from database
    func getAlbums() -> [Album] {
        let realm = try! Realm()
        return Array(realm.objects(Album.self))
    }
    
    // Fetchs all photos for album from vk
    func fetchPhotos(with albumID: Int, handler: @escaping ([Photo], Error?) -> Void) {
        VK.API.Photos.get([
            VK.Arg.albumId : String(albumID),
            VK.Arg.photoSizes : "1"
            ]).send(
                onSuccess: { response in
                    let photos = response["items"].array!.map(JSONParser.parsePhoto)
                    self.savePhotos(photos: photos, albumID: albumID)
                    handler(photos, nil)
            },
                onError: { error in
                    handler([], error)
            }
        )
    }
    
    // Gets all albums for album from database
    func getPhotos(with albumID: Int) -> [Photo] {
        let realm = try! Realm()
        return Array(realm.objects(Photo.self).filter("albumID == \(albumID)")).sorted { $0.0.date < $0.1.date }
    }
    
    // Saves array of objects of class T to database
    func saveArray<T : Object>(array: [T], type: T.Type) {
        let realm = try! Realm()
        array.forEach { object -> Void in
            try! realm.write {
                realm.create(type, value: object, update: true)
            }
        }
    }
    
    // Saves albums to database
    func saveAlbums(albums: [Album]) {
        let realm = try! Realm()
        try! realm.write {
            albums.forEach { album in
                realm.create(Album.self, value: album, update: true)
            }
            let albumsIDs = NSMutableSet(array: albums.map{ album in album.id })
            let removedAlbums = realm.objects(Album.self).filter { album in
                !albumsIDs.contains(album.id)
            }
            realm.delete(removedAlbums)
        }
    }
    
    // Saves photos to database
    func savePhotos(photos: [Photo], albumID: Int) {
        let realm = try! Realm()
        try! realm.write {
            photos.forEach { photo in
                realm.create(Photo.self, value: photo, update: true)
            }
            let photoIDs = NSMutableSet(array: photos.map { photo in photo.id })
            let removedPhoto = realm.objects(Photo.self).filter { photo in
                !photoIDs.contains(photo.id) && photo.albumID == albumID
            }
            realm.delete(removedPhoto)
        }
        
    }
    
    // Clear database
    func clearDatabase() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    // Post photo to wall
    func wallPost(photo: Photo, handler: @escaping (JSON?, Error?, (Int64, Int64)?) -> Void) {
        VK.API.Wall.post([VK.Arg.attachments : "photo\(Store.userID!)_\(photo.id)"]).send(
            onSuccess: { result in
                handler(result, nil, nil)
        },
            onError: { error in
                handler(nil, error, nil)
        },
            onProgress: { (part, full) in
                handler(nil, nil, (part, full))
        })
    }
    
    // Extract albums from database and update from web
    func extractAlbums(handler: @escaping ([Album], Error?, Source) -> Void) {
        let albums = getAlbums()
        if albums.count != 0 {
            handler(albums, nil, .database)
        }
        fetchAlbums { (albums, error) in
            handler(albums, error, .server)
        }
    }
    
    // Extract photos from database and update from web
    func extractPhotos(albumID: Int, handler: @escaping ([Photo], Error?, Source) -> Void) {
        let photos = getPhotos(with: albumID)
        if photos.count != 0 {
            handler(photos, nil, .database)
        }
        fetchPhotos(with: albumID) { (photos, error) in
            handler(photos, error, .server)
        }
    }
}










