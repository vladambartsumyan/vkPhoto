//
//  AlbumTableViewCell.swift
//  vkPhoto
//
//  Created by Владислав Амбарцумян on 11.03.17.
//  Copyright © 2017 Владислав Амбарцумян. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var albumSize: UILabel!
    
    @IBOutlet weak var cover: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
