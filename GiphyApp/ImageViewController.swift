//
//  ImageViewController.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 29/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit
import Kingfisher

class ImageViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var ok: UIButton!
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        if let url = URL(string: url) {
            image.kf.setImage(with: url)
        }
        image.layer.borderColor   = UIColor.darkGray.cgColor
        image.layer.borderWidth   = 1.0
        image.layer.cornerRadius  = image.bounds.width / 2.0
        image.layer.masksToBounds = true
        
        ok.layer.cornerRadius = 6.0
    }
    
    static func instantiate(url: String) -> ImageViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instance = storyboard.instantiateViewController(withIdentifier: ImageViewController.storyboardId) as! ImageViewController
        instance.url = url
        return instance
    }
    
    @IBAction func okButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
