//
//  CustomPlaceholderTF.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@IBDesignable
class CustomPlaceholderTF: UITextField {

  // Constants
  let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)

  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  override func draw(_ rect: CGRect) {
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                      NSAttributedString.Key.font: UIFont(
                        name: "Avenir Next",
                        size: 14)]
    let attributedPlaceholder = NSAttributedString(
      string: placeholder ?? "",
      attributes: attributes as [NSAttributedString.Key : Any])
    self.attributedPlaceholder = attributedPlaceholder
    self.clipsToBounds = true
    layer.cornerRadius = layer.bounds.size.height / 2
    super.draw(rect)
  }
}
