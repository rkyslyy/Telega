//
//  File.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation
import BCryptSwift
import Alamofire
import SwiftyRSA
import SocketIO

class TelegaAPI {
    
    class func establishConnection() {
        SocketService.instance.establishConnection()
    }
    
    class func emitReadMessagesFrom(id: String) {
        SocketService.instance.manager.defaultSocket.emit("messages_read",
                                                          id,
                                                          DataService.instance.id!)
    }
    
    class func disconnect() {
        SocketService.instance.manager.defaultSocket.disconnect()
    }
}
