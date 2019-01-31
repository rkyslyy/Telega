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

class AuthService {
    static let instanse = AuthService()
    
    var token : String? {
        get {
            return UserDefaults.standard.string(forKey: "userToken")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userToken")
        }
    }
    
    func registerUserWith(email: String,
                          password: String,
                          username: String, completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        DispatchQueue.global().async {
            do {
                let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
                let salt = BCryptSwift.generateSaltWithNumberOfRounds(10)
                guard let hashedPassword = BCryptSwift.hashPassword(password, withSalt: salt) else { return }
                guard let url = URL(string: USERS_URL) else { return }
                let body = [
                    "email": email,
                    "password": hashedPassword,
                    "username": username,
                    "avatar": "base64",
                    "privatePem": try keyPair.privateKey.pemString(),
                    "publicPem": try keyPair.publicKey.pemString()
                ]
                Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
                    self.dealWithRegResponse(response: response, completion: completion)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func dealWithRegResponse(response: DataResponse<Any>,
                                     completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        guard let data = response.value as? [String : Any] else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        return completion(true, data["message"] as! String)
    }
}
