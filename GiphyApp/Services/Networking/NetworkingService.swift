//
//  APIRouter.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkingService {
    
    let baseUrl = "https://api.giphy.com/v1/"
    let apiKey = "b56b49fa20b045d0aa9a3b1c24825e12"
    
    let networkingManager = Alamofire.SessionManager()
    
    func getImages(_ limit: Int, completion: @escaping ([Images]?) -> Void) {
        let url = URL(string: baseUrl + "gifs/trending?api_key=" + apiKey)
        let parameters = ["limit" : limit, "rating" : "G"] as [String : Any]
        
        networkingManager.request(url!, parameters: parameters)
            .responseJSON() { response in
                guard response.result.isSuccess else {
                    completion(nil)
                    return
                }
                let json = JSON(response.result.value as Any)["data"]
                let result = json.map({ Images(json: $0.1) })
                completion(result)
        }
    }
    
    func searchImages(q: String, limit: Int, offset: Int, completion: @escaping ([Images]?) -> Void) {
        let url = URL(string: baseUrl + "gifs/search?api_key=" + apiKey)
        let parameters = ["q"      : q,
                          "limit"  : limit,
                          "offset" : offset,
                          "rating" : "G",
                          "lang"   : "ru"] as [String : Any]
        
        networkingManager.request(url!, parameters: parameters)
            .responseJSON() { response in
                guard response.result.isSuccess else {
                    completion(nil)
                    return
                }
                let json = JSON(response.result.value as Any)["data"]
                let result = json.map({ Images(json: $0.1) })
                completion(result)
        }
    }
}





