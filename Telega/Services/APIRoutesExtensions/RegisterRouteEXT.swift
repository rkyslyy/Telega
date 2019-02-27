//
//  RegisterRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
  
  class func registerUserWith(
    email: String,
    password: String,
    username: String,
    completion: @escaping (_ result: Bool, _ message: String) -> ()) {
    DispatchQueue.global().async {
      guard let defaultImageData = UIImage(named: "boy")?.pngData() else {
        return completion(false, "Could not get data from default avatar")
      }
      guard let pems = EncryptionService.getStringPemsUsing(
        encryptionKey: password) else {
          return completion(false, "Could not get pems")
      }
      let base64 = defaultImageData.base64EncodedString()
      let body = ["email": email,
                  "password": password,
                  "username": username,
                  "avatar": base64,
                  "privatePem": pems.privatePem,
                  "publicPem": pems.publicPem]
      Alamofire.request(
        USERS_URL,
        method: .post,
        parameters: body,
        encoding: JSONEncoding.default,
        headers: HEADER)
        .responseJSON { (response) in
          guard let data = response.value as? [String : Any] else {
            return completion(false, "Something went wrong")
          }
          if let error = data["error"] {
            return completion(
              false,
              error as? String ?? "Something went wrong")
          }
          completion(true, data["message"] as? String ?? "Something went wrong")
      }
    }
  }
}
