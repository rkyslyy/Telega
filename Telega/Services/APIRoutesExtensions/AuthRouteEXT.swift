//
//  AuthRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
  
  class func authorizeUserWith(
    email: String,
    password: String,
    completion: @escaping (_ result: Bool, _ message: String) -> ()) {
    DispatchQueue.global().async {
      let body = [
        "email": email,
        "password": password
      ]
      Alamofire.request(
        AUTH_URL,
        method: .post,
        parameters: body,
        encoding: JSONEncoding.default,
        headers: HEADER)
        .responseJSON { (response) in
          guard let data = response.value as? [String : Any] else {
            return completion(false, "Could not get proper response")
          }
          if let error = data["error"] {
            return completion(false, error as? String ?? "Something went wrong")
          }
          guard let token = data["token"] as? String else {
            return completion(false, "Could not get token")
          }
          guard let encPrivatePem = data["privatePem"] as? String
            else {
              return completion(false, "Could not get private pem")
          }
          guard let privatePem = EncryptionService.decryptString(
            encryptedString: encPrivatePem,
            encryptionKey: password) else {
              return completion(false, "Could not decrypt private pem")
          }
          DataService.instance.token = token
          DataService.instance.privatePem = privatePem
          getInfoAboutSelf {
            TelegaAPI.establishConnection()
            completion(true, "Logged in as \(data["username"] as! String)")
          }
      }
    }
  }
}
