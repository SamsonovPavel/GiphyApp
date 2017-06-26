//
//  ImagesCollectionViewCell.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit
import Kingfisher

class ImagesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(images: Images) {
        
        if let url = URL(string: images.url) {
            cellImageView.kf.setImage(with: url)
        }
    }
}
