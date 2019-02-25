//
//  DarkNavigationVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftEntryKit

class DarkNavigationVC: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(showEntry(notification:)),
			name: MESSAGES_UPDATED,
			object: nil)
	}

	@objc func showEntry(notification: Notification) {
		guard let userinfo = notification.userInfo,
				  let id = userinfo["id"] as? String,
					let text = userinfo["text"] as? String
		else { return }
		if let dialogueVC = visibleViewController as? DialogueVC {
			if dialogueVC.companion.id == id {
				return
			}
		}
		for contact in DataService.instance.contacts! where contact.id == id {
			var attributes = EKAttributes.topFloat
			attributes.entryBackground = .color(color: #colorLiteral(red: 0.1780376285, green: 0.1780376285, blue: 0.1780376285, alpha: 1))
			attributes.popBehavior = .animated(
				animation: .init(
					translate: .init(duration: 0.3),
					scale: .init(from: 1, to: 0.7, duration: 0.7)))
			attributes.shadow = .active(
				with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
			attributes.statusBar = .light
			attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
			let title = EKProperty.LabelContent(
				text: "Message from " + contact.username,
				style: .init(
					font: UIFont(name: "Avenir-Medium", size: 16)!,
					color: UIColor.white))
			let description = EKProperty.LabelContent(
				text: text,
				style: .init(
					font: UIFont(name: "Avenir", size: 14)!,
					color: UIColor.white))
			let simpleMessage = EKSimpleMessage(
				title: title,
				description: description)
			let notificationMessage = EKNotificationMessage(
				simpleMessage: simpleMessage)
			let contentView = EKNotificationMessageView(with: notificationMessage)
			SwiftEntryKit.display(entry: contentView, using: attributes)
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
