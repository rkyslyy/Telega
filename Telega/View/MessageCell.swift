//
//  MessageCell.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/8/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var leftCon: NSLayoutConstraint!
  @IBOutlet weak var rightCon: NSLayoutConstraint!
  @IBOutlet weak var messageText: UILabel!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var timeLbl: UILabel!
  
  // Variables
  var lanchor: NSLayoutConstraint!
  var ranchor: NSLayoutConstraint!
  var mine: Bool!
  var tail: UIImageView?
  
  override func draw(_ rect: CGRect) {
    resetTail()
    super.draw(rect)
  }
  
  func resetTail() {
    tail?.removeFromSuperview()
    if !mine {
      tail = UIImageView(
        frame: CGRect(x: 6, y: frame.height - 29, width: 20, height: 20))
      tail?.image = UIImage(named: "tail")
      guard let templateImage = tail?.image?.withRenderingMode(
        UIImage.RenderingMode.alwaysTemplate)
        else { tail = nil; return }
      tail?.image = templateImage
      tail?.tintColor = #colorLiteral(red: 0.2126879096, green: 0.2239724994, blue: 0.265286684, alpha: 1)
      self.insertSubview(tail!, at: 0)
    } else {
      tail = UIImageView(
        frame: CGRect(
          x: frame.width - 6 - 20,
          y: frame.height - 29,
          width: 20,
          height: 20))
      tail?.image = UIImage(named: "tail")
      tail?.transform = CGAffineTransform(scaleX: -1, y: 1)
      guard let templateImage = tail?.image?.withRenderingMode(
        UIImage.RenderingMode.alwaysTemplate)
        else { tail = nil; return }
      tail?.image = templateImage
      tail?.tintColor = #colorLiteral(red: 0.2126879096, green: 0.2239724994, blue: 0.265286684, alpha: 1)
      self.insertSubview(tail!, at: 0)
    }
  }
}
