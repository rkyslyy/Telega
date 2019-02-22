//
//  MessagesRoute.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {

  class func send(
    message: String,
    toUserWithID id: String,
    andStoreCopyForMe messageForMe: String,
    completion: @escaping (String) -> ()) {
    let header = ["x-auth-token": DataService.instance.token!]
    let body = ["messageForMe": messageForMe,
                "messageForThem": message,
                "theirID": id,
                "socketID": SocketService.instance.manager.defaultSocket.sid]
    Alamofire.request(
      MESSAGES_URL,
      method: .post,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: header)
      .responseJSON { (response) in
        guard let data = response.value as? [String : Any]
          else { return completion(":(") }
        let time = data["time"] as! String
        completion(time)
    }
  }
}
