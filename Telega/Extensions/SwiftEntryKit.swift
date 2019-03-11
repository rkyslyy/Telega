//
//  SwiftEntryKit.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import SwiftEntryKit

extension SwiftEntryKit {
  class func displayNew(
    message: String,
    from username: String,
    contact: User?,
    viewController: UIViewController?
    ) {
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
    if contact != nil && viewController != nil {
      let action = {
        viewController!.performSegue(
          withIdentifier: "toDialogue",
          sender: contact)
      }
      attributes.entryInteraction.customTapActions.append(action)
    }
    let title = EKProperty.LabelContent(
      text: "Message from " + username,
      style: .init(
        font: UIFont(name: "Avenir-Medium", size: 16)!,
        color: UIColor.white))
    let description = EKProperty.LabelContent(
      text: message,
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

  class func displayFriendRequestFrom(username: String) {
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
      text: "New friend request",
      style: .init(
        font: UIFont(name: "Avenir-Medium", size: 16)!,
        color: UIColor.white))
    let description = EKProperty.LabelContent(
      text: username + " wants to be friends",
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
