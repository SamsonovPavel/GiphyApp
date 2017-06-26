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
    
    convenience init(json: JSON) {
        self.init()
        id = json["id"].stringValue
        url = json["images"]["original"]["url"].stringValue
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
