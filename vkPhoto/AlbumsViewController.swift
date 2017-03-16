//
//  AlbumViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 12.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import SwiftyVK
import SDWebImage

class AlbumsViewController: LiveViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let navigationItemTitle = "Альбомы"
    
    var albums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VK.config.language = "ru"
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAlbums()
    }
    
    func loadAlbums() {
        
        guard reachability.isReachable else {
            albums = Store.repository.getAlbums()
            offlineMode()
            if !LiveViewController.errorWasPresented {
                showConnectionError()
            }
            return
        }
        
        startLoading()
        Store.repository.extractAlbums { (albums, error, source) in
            if error != nil {
                if source == .server {
                    self.stopLoading()
                    self.offlineMode()
                }
            } else {
                if source == .server {
                    self.stopLoading()
                    self.onlineMode()
                }
                self.albums = albums
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "album") as! AlbumTableViewCell
        let album = albums[indexPath.row]
        cell.title.text = album.title
        cell.albumSize.text = "\(album.size)"
        cell.cover.layer.cornerRadius = cell.cover.frame.width / 2
        cell.cover.sd_setImage(with: URL(string: album.coverURL)!) { (image, error, cacheType, imageURL) -> Void in
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "openAlbum", sender: albums[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let album = sender as! Album
        let dvc = segue.destination as! PhotosViewController
        dvc.album = album
    }
    
    @IBAction func exitTouched(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: nil, message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        
        let cancel = UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: "Выйти", style: .default) { action in
            VK.logOut()
            Store.repository.clearDatabase()
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "authorization") as! AuthorizationViewController
            viewController.needAnimation = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            UIView.transition(with: appDelegate.window!, duration: 0.8, options: .transitionCrossDissolve, animations: {
                appDelegate.window?.rootViewController = viewController
            }, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateTouched(_ sender: UIBarButtonItem) {
        if reachability.isReachable {
            loadAlbums()
        } else {
            offlineMode()
            let alert = UIAlertController.init(title: nil, message: "Нет доступа к сети", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
