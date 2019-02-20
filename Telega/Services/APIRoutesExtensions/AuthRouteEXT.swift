//
//  AuthRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
    
    class func authorizeUserWith(email: String,
                           password: String,
                           completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        DispatchQueue.global().async {
            let body = [
                "email": email,
                "password": password
            ]
            Alamofire.request(AUTH_URL,
                              method: .post,
                              parameters: body,
                              encoding: JSONEncoding.default,
                              headers: HEADER).responseJSON(completionHandler: { (response) in
                self.dealWithAuthResponse(password: password, response: response, completion: completion)
            })
        }
    }
    
    private class func dealWithAuthResponse(password: String, response: DataResponse<Any>,
                                      completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        
        guard let data = response.value as? [String : Any]
            else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        DataService.instance.token = (data["token"] as! String)
        let encryptedPrivatePem = data["privatePem"] as! String
        guard let privatePem = EncryptionService.decryptString(encryptedString: encryptedPrivatePem,
                                                               encryptionKey: password)
            else { completion(false, "Could not decrypt private pem"); return }
        DataService.instance.privatePem = privatePem
        getInfoAboutSelf {
            TelegaAPI.establishConnection()
            completion(true, "Logged in as \(data["username"] as! String)")
        }
    }
}
