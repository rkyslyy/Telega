//
//  CircleImageView.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {
  
  @IBInspectable var circle: Bool = false {
    didSet {
      if circle {
        layer.cornerRadius = frame.width / 2
      } else {
        layer.cornerRadius = 0
      }
    }
  }
}
