//
//  UIView.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

extension UIView {
  
  func shake() {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(
      name: CAMediaTimingFunctionName.linear)
    animation.duration = 0.6
    animation.values = [-10.0, 10.0, -10.0, 10.0, -7.0, 7.0, -5.0, 5.0, 0.0]
    layer.add(animation, forKey: "shake")
  }
  
  func bindToKeyboard() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)
  }
  
  @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
    let duration = notification
      .userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
    let curve = notification
      .userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
    let beginningFrame = notification
      .userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
    let endingFrame = notification
      .userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    let deltaY = beginningFrame.origin.y - endingFrame.origin.y
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0.0,
      options: UIView.KeyframeAnimationOptions(rawValue: curve),
      animations: {
        self.frame.size.height -= deltaY
    }, completion: nil)
  }
  
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(
      roundedRect: bounds,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}

