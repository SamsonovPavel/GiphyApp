//
//  Images.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Images: Object {
    dynamic var id = ""
    dynamic var url = ""
    dynamic var original = ""
    
    convenience init(json: JSON) {
        self.init()
        id = json["id"].stringValue
        url = json["images"]["fixed_width"]["url"].stringValue
        original = json["images"]["original"]["url"].stringValue
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
