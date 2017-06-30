//
//  ReachabilityManager.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 30/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import Foundation
import Alamofire

let listenerReachableNotification = NSNotification.Name(rawValue: "NSNotificationKeyListenerReachableNotification")
let listenerNotReachableNotification = NSNotification.Name(rawValue: "NSNotificationKeyListenerNotReachableNotification")

enum ReachabilityManagerError: Error {
    case notReachable
}

class ReachabilityManager {
    let networkManager = NetworkReachabilityManager()!
    
    static var shared: ReachabilityManager = {
        return ReachabilityManager()
    }()
    
    //MARK:-
    //MARK: listening
    func startNetworkListening() {
        networkManager.listener = { status in
            switch status {
            case .reachable   : NotificationCenter.default.post(Notification(name: listenerReachableNotification))
            case .notReachable: NotificationCenter.default.post(Notification(name: listenerNotReachableNotification))
            default: break
            }
        }
        self.networkManager.startListening()
    }
    func stopNetworkListening() {
        networkManager.stopListening()
    }
}
