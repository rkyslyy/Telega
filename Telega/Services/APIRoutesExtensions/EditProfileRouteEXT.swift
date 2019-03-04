//
//  EditProfileRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
  
  class func editProfileWith(
    username: String,
    andAvatar avatar: String,
    completion: @escaping () -> ()) {
    if DataService.instance.token != nil {
      DispatchQueue.global().async {
        let body = ["username": username,
                    "avatar": avatar]
        Alamofire.request(
          USERS_URL,
          method: .put,
          parameters: body,
          encoding: JSONEncoding.default,
          headers: AUTH_HEADER)
          .responseJSON { (response) in
            guard let data = response.value as? [String : Any]
              else { print("response:", response); return }
            if data["error"] == nil {
              DataService.instance.username = username
              DataService.instance.userAvatar = avatar
              TelegaAPI.emitSettingsChanged(username: username, avatar: avatar)
              completion()
            } else {
              completion()
            }
        }
      }
    }
  }
  
  class func changePasswordTo(
    _ password: String,
    withPem pem: String,
    completion: @escaping () -> ()) {
    let body = ["password": password,
                "pem": pem]
    Alamofire.request(
      CHANGE_PASSWORD_URL,
      method: .put,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: AUTH_HEADER)
      .responseJSON { (response) in
        completion()
    }
  }
}
