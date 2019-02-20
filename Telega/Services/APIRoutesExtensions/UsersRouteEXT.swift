//
//  UsersRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
    class func acceptFriendRequestFrom(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "friendID": id
            ]
            Alamofire.request(ACCEPT_FRIEND_REQUEST_URL,
                              method: .post,
                              parameters: body,
                              encoding: JSONEncoding.default,
                              headers: header).responseJSON(completionHandler: { (response) in
                                self.getInfoAboutSelf {
                    completion()
                }
            })
        }
    }
    
    class func addContactWith(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "contact": id
            ]
            Alamofire.request(ADD_CONTACT_URL,
                              method: .put,
                              parameters: body,
                              encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                completion()
            })
        }
    }
    
    class func deleteContactWith(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "contact": id
            ]
            Alamofire.request(DELETE_CONTACT_URL,
                              method: .put,
                              parameters: body,
                              encoding: JSONEncoding.default,
                              headers: header).responseJSON(completionHandler: { (response) in
                completion()
            })
        }
    }
    
    class func getUserFor(email: String, completion: @escaping (User?) -> ()) {
        DispatchQueue.global().async {
            Alamofire.request(USERS_SEARCH_URL + "email=" + email, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON(completionHandler: { (response) in
                guard let data = response.value as? [String : Any]
                    else { print(response); return }
                if data["error"] == nil {
                    completion(User(id: data["_id"] as! String, email: data["email"] as! String, username: data["username"] as! String, avatar: data["avatar"] as! String, publicPem: data["publicPem"] as! String, confirmed: false, requestIsMine: true, online: false, unread: false))
                } else {
                    completion(nil)
                }
            })
        }
    }
}
