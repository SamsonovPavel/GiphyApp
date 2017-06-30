//
//  ActivityIndicator.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 30/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit

class ActivityIndicator {
    var containerView     = UIView()
    var loadingView       = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    public func showActivityIndicator(_ view: UIView) {
        let y = Float((UIScreen.main.bounds.size.height / 2.0) - (UIScreen.main.bounds.size.height / 16.0))
        
        containerView.frame           = UIScreen.main.bounds
        containerView.center          = CGPoint(x: UIScreen.main.bounds.size.width / 2.0,
                                                y: CGFloat(y))
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        
        loadingView.frame              = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center             = containerView.center
        loadingView.backgroundColor    = UIColor(hex: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds      = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.bounds.width / 2, y: loadingView.bounds.height / 2)
        
        loadingView.addSubview(activityIndicator)
        containerView.addSubview(loadingView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
        let blue  = CGFloat(hex & 0xFF) / 256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

