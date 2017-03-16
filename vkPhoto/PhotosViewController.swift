//
//  PhotosViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 12.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import SwiftyVK

class PhotosViewController: LiveViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var errorImage: UIImageView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var additionalView: UIView? = nil
    
    var album: Album!
    
    var photos: [Photo] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.navigationItem.title = album.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPhotos()
        self.view.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func loadPhotos() {
        
        guard InternetConnectionChecker.check() else {
            self.photos = Store.repository.getPhotos(with: album.id)
            self.offlineMode(shouldShowError: false)
            DispatchQueue.main.async {
                if self.photos.count == 0 && self.album.size != 0 {
                    self.showCloud()
                }
                if self.photos.count == 0 && self.album.size == 0 {
                    self.showEmpty()
                }
                if self.photos.count != 0 {
                    self.self.hideAll()
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        startLoadIndication()
        Store.repository.extractPhotos(albumID: album.id) { (photos, error, source) in
            if source == .server {
                self.stopLoadIndication()
            }
            if error == nil {
                self.photos = photos
                DispatchQueue.main.async {
                    if photos.count == 0 && source == .server {
                        self.showEmpty()
                    } else {
                        self.hideAll()
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    if self.photos.count == 0 {
                        self.showCloud()
                    } else {
                        self.hideAll()
                    }
                }
                self.offlineMode(shouldShowError: false)
            }
        }
    }
    
    func hideAll() {
        tableView.isHidden = false
        errorImage.isHidden = true
        errorLabel.isHidden = true
    }
    
    func showCloud() {
        errorImage.image = #imageLiteral(resourceName: "sad_black.png")
        errorImage.isHidden = false
        errorLabel.text = "Не удалось загрузить фотографии"
        errorLabel.isHidden = false
        tableView.isHidden = true
    }
    
    func showEmpty() {
        errorImage.image = #imageLiteral(resourceName: "photo.png")
        errorImage.isHidden = false
        errorLabel.text = "Альбом пуст"
        errorLabel.isHidden = false
        tableView.isHidden = true
    }
    
    func addSubview() {
        self.view.addSubview(self.additionalView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "ru")
        let formatString = "dd MMM yyyy MM:HH"
        dateFormatter.dateFormat = formatString
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "photo") as! PhotoTableViewCell
        let photo = photos[indexPath.row]
        if photo.text == "" {
            cell.title.text = "Без подписи"
            cell.title.textColor = UIColor.init(white: 0.65, alpha: 1)
        } else {
            cell.title.text = photo.text
            cell.title.textColor = UIColor.init(white: 60/255, alpha: 1)
        }
        cell.date.text = dateFormatter.string(from: photo.date)
        cell.photo.layer.cornerRadius = cell.photo.frame.width / 2
        cell.activityIndicator.startAnimating()
        cell.photo.sd_setImage(with: URL(string: photo.smallPhoto)!) { (image, error, cacheType, imageURL) -> Void in
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "openPhoto", sender: photos[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photo = sender as! Photo
        let dvc = segue.destination as! ConcretePhotoViewController
        dvc.photo = photo
    }
    
    override func reloadData() {
        loadPhotos()
    }
    
    @IBAction func updateTouched(_ sender: UIBarButtonItem) {
        if InternetConnectionChecker.check() {
            onlineMode()
            loadPhotos()
        } else {
            DispatchQueue.main.async {
                self.offlineMode(shouldShowError: true)
            }
        }
    }
}
