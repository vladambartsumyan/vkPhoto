//
//  ConcretePhotoViewController.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 13.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps

class ConcretePhotoViewController: LiveViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var oldZoom: CGFloat = 1.0
    
    var photo: Photo!
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var photoTitle: UILabel!
    
    @IBOutlet weak var background: UIView!
    
    var map: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setPhotoTitle()
        loadPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setTitle() {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "ru")
        dateFormatter.dateFormat = "dd MMM YYYY"
        self.navigationItem.title = dateFormatter.string(from: photo.date)
    }
    
    func setPhotoTitle() {
        photoTitle.text = photo.text
    }
    
    func loadPhoto() {
        activityIndicator.startAnimating()
        photoImage.sd_setImage(with: URL(string: photo.bigPhoto)!) { (image, error, cacheType, imageURL) -> Void in
            self.activityIndicator.stopAnimating()
            if image == nil {
                self.showSadCloud()
                self.offlineMode(shouldShowError: false)
            }
        }
    }

    func showSadCloud() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let sadCloudVC = storyboard.instantiateViewController(withIdentifier: "sadCloud")
        let sadCloudView = sadCloudVC.view!
        sadCloudView.frame.size = CGSize.init(width: 300, height: 200)
        sadCloudView.backgroundColor = UIColor.clear
        sadCloudView.alpha = 0.8
        sadCloudView.center = self.view.center
        DispatchQueue.main.async {
            self.view.addSubview(sadCloudView)
        }
    }
    
    func configMapView() {
        guard map == nil && photo.latitude.value != nil else { return }
        map = GMSMapView()
        let location = CLLocationCoordinate2D.init(latitude: photo.latitude.value!, longitude: photo.longitude.value!)
        map!.camera = GMSCameraPosition.camera(withTarget: location, zoom: 13)
        let marker = GMSMarker.init(position: location)
        marker.map = map!
        
        map!.frame = CGRect.init(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.width / 2)
        
        self.view.addSubview(map!)
        
    }
    
    func showAdditionalInfo() {
        guard photo.text != "" || map != nil else { return }
        
        
        background.isHidden = false
        let deltaY = self.map?.frame.height ?? 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.background.alpha = 0.8
            self.map?.frame.origin.y -= deltaY
            self.photoTitle.frame.origin.y -= deltaY
            self.photoTitle.alpha = 1        }
    }
    
    func hideAdditionalInfo() {
        let deltaY = self.map?.frame.height ?? 0
        UIView.animate(withDuration: 0.5, animations: {
            self.background.alpha = 0
            self.map?.frame.origin.y += deltaY
            self.photoTitle.frame.origin.y += deltaY
            self.photoTitle.alpha = 0
        }, completion: { finished in
            if finished {
                self.background.isHidden = true
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        
        scrollView.zoomScale = oldZoom * sender.scale
        if sender.state == .ended {
            oldZoom = scrollView.zoomScale
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImage
    }
    
    @IBAction func postToWall(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Вы уверены, что хотите загрузить фото на стену?", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: "OK", style: .default) { action in
            self.progressBar.progress = 0
            self.progressBar.isHidden = false
            Store.repository.wallPost(photo: self.photo) { (result, error, progress) in
                if result != nil {
                    DispatchQueue.main.async { self.progressBar.isHidden = true }
                }
                if error != nil {
                    DispatchQueue.main.async { self.progressBar.isHidden = true }
                }
                if progress != nil {
                    DispatchQueue.main.async { self.progressBar.progress = Float(progress!.0) / Float(progress!.1) }
                }
            }
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func photoTouched(_ sender: UITapGestureRecognizer) {
        self.configMapView()
        showAdditionalInfo()
    }
    
    @IBAction func backgroundTouched(_ sender: UITapGestureRecognizer) {
        hideAdditionalInfo()
    }
}
