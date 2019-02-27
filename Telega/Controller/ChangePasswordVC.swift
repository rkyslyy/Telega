//
//  ChangePasswordVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/12/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu

class ChangePasswordVC: UIViewController {

  // Outlets
  @IBOutlet weak var blurredMask: UIVisualEffectView!
  @IBOutlet weak var window: RoundedView!
  @IBOutlet weak var windowHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var passTxtFld: CustomPlaceholderTF!
  @IBOutlet weak var confPassTxtFld: CustomPlaceholderTF!
  @IBOutlet weak var changeBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    blurredMask.alpha = 0
    window.alpha = 0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.2, animations: {
      self.blurredMask.alpha = 1
      self.window.alpha = 1
    }) { (_) in
      let tap = UITapGestureRecognizer(
        target: self,
        action: #selector(self.dismissSelf))
      self.blurredMask.addGestureRecognizer(tap)
    }
  }
  
  @objc private func dismissSelf() {
    if passTxtFld.isFirstResponder || confPassTxtFld.isFirstResponder {
      view.endEditing(true)
      return
    }
    UIView.animate(withDuration: 0.2, animations: {
      self.blurredMask.alpha = 0
      self.window.alpha = 0
    }) { (_) in
      self.presentingViewController?.dismiss(
        animated: false,
        completion: nil)
    }
  }
  
  @IBAction func changeBtnPressed(_ sender: Any) {
    guard let password =    passTxtFld.text,
      passTxtFld.text != ""
      else { return passTxtFld.shake() }
    if passTxtFld.text != confPassTxtFld.text {
      if confPassTxtFld.text != "" {
        passTxtFld.shake()
      }
      return confPassTxtFld.shake()
    }
    let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
    if password.range(
      of: regex,
      options: .regularExpression,
      range: nil,
      locale: nil) == nil {
      return showPasswordRules()
    }
    do {
      let encryptedPrivatePem = try self.encryptMessage(
        message: DataService.instance.privatePem!,
        encryptionKey: password)
      hideWindowContents()
      let ripple = GIFImageView(
        frame: CGRect(
          x: view.frame.width / 2 - 40,
          y: view.frame.height / 2 - 40,
          width: 80,
          height: 80))
      ripple.alpha = 0
      showRipple(ripple)
      TelegaAPI.changePasswordTo(
        password,
        withPem: encryptedPrivatePem) {
          self.view.endEditing(true)
          self.dismissSelf()
      }
    } catch { return }
  }
  
  func encryptMessage(message: String, encryptionKey: String) throws -> String {
    let messageData = message.data(using: .utf8)!
    let cipherData = RNCryptor.encrypt(
      data: messageData,
      withPassword: encryptionKey)
    return cipherData.base64EncodedString()
  }
  
  private func showRipple(_ ripple: GIFImageView) {
    view.addSubview(ripple)
    ripple.animate(withGIFNamed: "ripple")
    UIView.animate(withDuration: 0.2) {
      ripple.alpha = 1
    }
  }
  
  private func hideWindowContents() {
    UIView.animate(withDuration: 0.2) {
      self.passTxtFld.alpha = 0
      self.confPassTxtFld.alpha = 0
      self.changeBtn.alpha = 0
    }
  }
  
  private func showPasswordRules() {
    view.endEditing(true)
    let rules = PasswordRules(frame: self.window.bounds)
    rules.frame.size.width = self.window.bounds.width
    rules.frame.origin = self.window.frame.origin
    rules.contentView.alpha = 0
    rules.clipsToBounds = true
    rules.layer.cornerRadius = self.window.layer.cornerRadius
    self.view.addSubview(rules)
    UIView.animate(withDuration: 0.2,
                   animations: {
                    rules.contentView.alpha = 1
    }) { (_) in }
  }
}
