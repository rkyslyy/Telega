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
  }
  
//  @objc func showEntry(notification: Notification) {
//    guard let userinfo = notification.userInfo,
//      let id = userinfo["id"] as? String,
//      let text = userinfo["text"] as? String,
//      let mine = userinfo["mine"] as? Bool,
//      !(visibleViewController is ContactsVC),
//      !mine 
//    else { return }
//    if let dialogueVC = visibleViewController as? DialogueVC {
//      if dialogueVC.companion.id == id {
//        return
//      }
//    }
//    for contact in DataService.instance.contacts! where contact.id == id {
//      SwiftEntryKit.displayNew(
//        message: text,
//        from: contact.username,
//        contact: nil,
//        viewController: nil)
//    }
//  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
