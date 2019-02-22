//
//  UsersRouteEXT.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
	class func acceptFriendRequestFrom(
		id: String,
		completion: @escaping () -> ()) {
		DispatchQueue.global().async {
			let body = ["friendID": id]
			Alamofire.request(
				ACCEPT_FRIEND_REQUEST_URL,
				method: .post,
				parameters: body,
				encoding: JSONEncoding.default,
				headers: AUTH_HEADER)
				.responseJSON { (response) in
					self.getInfoAboutSelf { completion() }
			}
		}
	}

	class func addContactWith(id: String, completion: @escaping () -> ()) {
		DispatchQueue.global().async {
			let body = ["contact": id]
			Alamofire.request(
				ADD_CONTACT_URL,
				method: .put,
				parameters: body,
				encoding: JSONEncoding.default,
				headers: AUTH_HEADER)
				.responseJSON { (response) in completion() }
		}
	}

	class func deleteContactWith(id: String, completion: @escaping () -> ()) {
		DispatchQueue.global().async {
			let body = ["contact": id]
			Alamofire.request(
				DELETE_CONTACT_URL,
				method: .put,
				parameters: body,
				encoding: JSONEncoding.default,
				headers: AUTH_HEADER)
				.responseJSON { (response) in completion() }
		}
	}

	class func getUserFor(email: String, completion: @escaping (User?) -> ()) {
		DispatchQueue.global().async {
			Alamofire.request(
				USERS_SEARCH_URL + "email=" + email,
				method: .get,
				parameters: nil,
				encoding: JSONEncoding.default,
				headers: HEADER)
				.responseJSON { (response) in
					guard let data = response.value as? [String : Any] else {
						return print(response)
					}
					if data["error"] == nil {
						guard let id = data["_id"] as? String,
							let email = data["email"] as? String,
							let username = data["username"] as? String,
							let avatar = data["avatar"] as? String,
							let publicPem = data["publicPem"] as? String else {
								return completion(nil)
						}
						return completion(User(
							id: id,
							email: email,
							username: username,
							avatar: avatar,
							publicPem: publicPem,
							confirmed: false,
							requestIsMine: true,
							online: false,
							unread: false))
					}
					completion(nil)
			}
		}
	}
}
