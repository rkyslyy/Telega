//
//  DialogueVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/7/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import SwiftyRSA
import AVFoundation
import Gifu

class DialogueVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var messagesTable: UITableView!
  @IBOutlet weak var messageContentView: UIView!
  @IBOutlet weak var messageInputView: MessageInputView!
  @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var sendBtn: UIButton!
  @IBOutlet weak var noMessagesLbl: UILabel!

  // Variables
  var companion: User!
  var messageSound: AVAudioPlayer?
  var avatarBtn: UIButton!
  var avatarMask: UIView?
  var avatarImgView: UIImageView?
  var sendLoadingGif: GIFImageView?
  var requestPending = false
  var backupText: String!

  override func viewDidLoad() {
    super.viewDidLoad()
    let tap = UITapGestureRecognizer(
      target: self,
      action: #selector(hideKeyboard(tap:)))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
    view.bindToKeyboard()
    navigationItem.title = companion.username
    setupAvatarImgBtn()
    messagesTable.delegate = self
    messagesTable.dataSource = self
    messagesTable.transform = CGAffineTransform(rotationAngle: (-.pi))
    messageInputView.delegate = self
    messageInputView.text = "Type something"
    messageInputView.textColor = UIColor.darkGray
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(messagesUpdated(notification:)),
      name: MESSAGES_UPDATED,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(settingsChanged(notification:)),
      name: SETTINGS_CHANGED,
      object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    noMessagesLbl.isHidden = MessagesStorage.messagesExistWith(id: companion.id)
  }

  override func viewDidAppear(_ animated: Bool) {
    for (index, contact) in DataService.instance.contacts!.enumerated() {
      if contact.id == companion.id {
        DataService.instance.contacts![index].unread = false
      }
    }
    TelegaAPI.emitReadMessagesFrom(id: companion.id)
  }

  @objc private func setupAvatarImgBtn() {
    avatarBtn = UIButton(type: .custom)
    avatarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    avatarBtn.contentMode = .scaleAspectFit
    avatarBtn.clipsToBounds = true
    avatarBtn.layer.cornerRadius = 15
    let image = UIImage(data: Data(base64Encoded: companion.avatar)!)
    if image!.size.width <= 512 {
      avatarBtn.setImage(
        image!.resizedImageWithinRect(rectSize: CGSize(width: 40, height: 40)),
        for: .normal)
      avatarBtn.backgroundColor = .darkGray
      avatarBtn.layer.cornerRadius = 20
    } else {
      avatarBtn.setImage(
        image!.resizedImageWithinRect(rectSize: CGSize(width: 50, height: 50))
          .crop(rect: CGRect(x: 5, y: 5, width: 30, height: 30)),
        for: .normal)
    }
    avatarBtn.addTarget(self,
                        action: #selector(showAvatar),
                        for: .touchUpInside)
    let barButton = UIBarButtonItem(customView: avatarBtn)
    navigationItem.rightBarButtonItem = barButton
  }
  
  @objc private func settingsChanged(notification: Notification) {
    guard let userinfo = notification.userInfo,
      let id = userinfo["id"] as? String,
      id == companion.id
    else { return }
    for contact in DataService.instance.contacts! where contact.id == id {
      companion = contact
    }
    navigationItem.title = self.companion.username
    setupAvatarImgBtn()
  }
  
  @objc private func showAvatar() {
    if avatarMask != nil || avatarImgView != nil {
      return
    }
    avatarMask = UIView(frame: view.frame)
    avatarMask!.alpha = 0
    avatarMask!.backgroundColor = UIColor(white: 0, alpha: 0.7)
    view.addSubview(avatarMask!)
    avatarImgView = UIImageView(
      frame: CGRect(
        x: view.frame.width - 30,
        y: avatarBtn.frame.origin.y + 10,
        width: 1,
        height: 1))
    avatarImgView!.image = UIImage(data: Data(base64Encoded: companion.avatar)!)
    avatarImgView!.contentMode = .scaleAspectFit
    view.addSubview(avatarImgView!)
    UIView.animate(withDuration: 0.2, animations: {
      self.avatarMask!.alpha = 1
      self.avatarImgView!.frame = self.view.frame
    }, completion: { (_) in
      let tap = UITapGestureRecognizer(
        target: self,
        action: #selector(self.hideAvatar))
      self.avatarMask!.addGestureRecognizer(tap)
    })
  }
  
  @objc private func hideAvatar() {
    UIView.animate(withDuration: 0.2, animations: {
      self.avatarImgView?.frame = CGRect(
        x: self.view.frame.width - 30,
        y: self.avatarBtn.frame.origin.y + 10,
        width: 1,
        height: 1)
      self.avatarMask?.alpha = 0
    }, completion: { (_) in
      self.avatarImgView?.removeFromSuperview()
      self.avatarMask?.removeFromSuperview()
      self.avatarMask = nil
      self.avatarImgView = nil
    })
  }
  
  @objc private func hideKeyboard(tap: UITapGestureRecognizer) {
    let tapLocation = tap.location(in: sendBtn)
    if sendBtn.layer.contains(tapLocation) {
      return
    }
    view.endEditing(true)
  }
  
  @objc private func messagesUpdated(notification: Notification) {
    noMessagesLbl.isHidden = true
    TelegaAPI.emitReadMessagesFrom(id: companion.id)
    if let result = notification.userInfo?["storing_result"] as? StoringResult,
      let id = notification.userInfo?["id"] as? String,
      id == companion.id {
      switch result {
      case .freshContact, .freshDate: do { self.messagesTable.reloadData() }
      case .freshMessage: do {
        self.messagesTable.insertRows(
          at: [IndexPath(row: 0, section: 0)],
          with: .top)
        }
      }
      for (index, contact) in DataService.instance.contacts!.enumerated() {
        if contact.id == companion.id {
          DataService.instance.contacts![index].unread = false
        }
      }
    }
  }
  
  @IBAction func sendBtnPressed() {
    guard let (encryptedForMe,
               encryptedForCompanion) = EncryptionService.encryptedMessages(
                messageInputView.text!,
                withPublicKey: companion.publicKey),
          messageInputView.text != nil,
          messageInputView.text != ""
    else { return }
    let trimmedText = messageInputView.text!.trimmingCharacters(
      in: .whitespacesAndNewlines)
    sendLoading(shown: true)
    TelegaAPI.send(
      message: encryptedForCompanion,
      toUserWithID: companion.id,
      andStoreCopyForMe: encryptedForMe,
      completion: { timeStr in
        self.noMessagesLbl.isHidden = true
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EET")
        let time = dateFormatter.date(
          from:timeStr.components(separatedBy: ".")[0] + "-0200")!
        let newMessage = Message(text:trimmedText, time: time, mine: true)
        MessagesStorage.storeNew(
          message: newMessage,
          storeID: self.companion.id,
          timeStr: timeStr,
          completion: { (result) in
            switch result {
            case .freshContact, .freshDate:
              do { self.messagesTable.reloadData() }
            case .freshMessage: do {
              self.messagesTable.insertRows(
                at: [IndexPath(row: 0, section: 0)],
                with: .top)
              }
            }
        })
        self.sendLoading(shown: false)
    })
  }

  private func sendLoading(shown: Bool) {
    if shown {
      sendBtn.isEnabled = false
      sendBtn.isHidden = true
      requestPending = true
      sendLoadingGif = GIFImageView(frame: sendBtn.frame)
      sendLoadingGif!.animate(withGIFNamed: "ripple")
      messageContentView.addSubview(sendLoadingGif!)
    } else {
      self.requestPending = false
      self.messageInputView.text = ""
      self.messageViewHeightConstraint.constant = 58.0
      self.sendBtn.isEnabled = true
      self.sendBtn.isHidden = false
      sendLoadingGif?.removeFromSuperview()
    }
  }
}

extension DialogueVC: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.darkGray {
      textView.text = nil
      textView.textColor = UIColor.white
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Type something"
      textView.textColor = UIColor.darkGray
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if requestPending
    { return textView.text = backupText }
    let fixedWidth = textView.frame.size.width
    let newSize = textView.sizeThatFits(CGSize(
      width: fixedWidth,
      height: CGFloat.greatestFiniteMagnitude))
    messageViewHeightConstraint.constant = newSize.height + 20
    backupText = textView.text
  }
}

extension DialogueVC: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return MessagesStorage.numberOfDatesBy(user: companion.id)
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
    ) -> Int {
    return MessagesStorage.numberOfMessagesBy(
      dateIndex: section,
      andContact: companion.id)
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "messageCell") as! MessageCell
    cell.transform = CGAffineTransform(rotationAngle: (-.pi))
    if let messages = MessagesStorage.messagesOfContactWith(
      id: companion.id,
      andOfDateIndex: indexPath.section) {
      let message = messages[indexPath.row]
      var text = message.text
      if text.count <= 5 {
        for _ in 0..<10 - text.count {
          text += " "
        }
      }
      cell.messageText.text = text
      cell.lanchor = cell.leftCon
      cell.ranchor = cell.rightCon
      cell.infoView.clipsToBounds = true
      cell.infoView.layer.cornerRadius = 10
      cell.infoView.layer.maskedCorners = [.layerMaxXMaxYCorner,
                                           .layerMinXMaxYCorner]
      let timi = message.time.description.components(separatedBy: " ")[1]
      let hours = timi.components(separatedBy: ":")[0]
      let minutes = timi.components(separatedBy: ":")[1]
      cell.timeLbl.text = hours + ":" + minutes
      if messages[indexPath.row].mine {
        cell.lanchor.isActive = false
        cell.ranchor.isActive = true
        if cell.messageText.text?.count ?? 0 >= 35 {
          cell.lanchor.isActive = true
        }
        cell.mine = true
      } else {
        cell.lanchor.isActive = true
        cell.ranchor.isActive = false
        if cell.messageText.text?.count ?? 0 >= 35 {
          cell.ranchor.isActive = true
        }
        cell.mine = false
      }
      return cell
    } else {
      return cell
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    didEndDisplaying cell: UITableViewCell,
    forRowAt indexPath: IndexPath
    ) {
    if let cell = tableView.dequeueReusableCell(
      withIdentifier: "messageCell") as? MessageCell {
      cell.tail?.removeFromSuperview()
      cell.tail = nil
    }
  }
  
  func tableView(_ tableView: UITableView,
                 viewForFooterInSection section: Int) -> UIView? {
    let label = UILabel(frame: CGRect(
      x: 0,
      y: 0,
      width: tableView.frame.width,
      height: 20))
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                      NSAttributedString.Key.font: UIFont(
                        name: "Avenir Next",
                        size: 14)!
    ]
    guard var sectionDateStr = MessagesStorage.dateStringForIndex(
      section,
      forID: companion.id)
      else { return nil }
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy:MM:dd"
    let result = formatter.string(from: date)
    let todayStr = result.components(separatedBy: " ")[0]
    if sectionDateStr == todayStr.replacingOccurrences(of: ":", with: "-") {
      sectionDateStr = "Today"
    } else {
      let year = sectionDateStr.components(separatedBy: "-")[0]
      var monthStr = sectionDateStr.components(separatedBy: "-")[1]
      if monthStr.first == "0" {
        monthStr.removeFirst()
      }
      let month = months[Int(monthStr)! - 1]!
      let day = sectionDateStr.components(separatedBy: "-")[2]
      sectionDateStr = "\(day) \(month), \(year)"
    }
    let text = NSMutableAttributedString(
      string: sectionDateStr,
      attributes: attributes)
    label.attributedText = text
    label.textAlignment = .center
    label.textColor = .darkGray
    label.transform = CGAffineTransform(scaleX: -1, y: -1)
    return label
  }
}
