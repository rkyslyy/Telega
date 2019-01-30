//
//  RoundedView.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
}
