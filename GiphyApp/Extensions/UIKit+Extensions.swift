//
//  UIKit+Extensions.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit

extension UIView {
    static var reuseId: String {
        return String(describing: self)
    }
}

extension UIViewController {
    static var storyboardId: String {
        return String(describing: self)
    }
}
