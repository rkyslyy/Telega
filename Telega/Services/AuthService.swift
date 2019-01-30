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
                          username: String, completion: @escaping (_ result: Bool) -> ()) {
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
                    guard let data = response.value as? [String : Any] else { print("could not read data: \(response.value ?? "no value")" ); completion(false); return }
                    guard let token = data["token"] as? String else { print("could not get token" ); completion(false); return }
                    self.token = token
                    completion(true)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
