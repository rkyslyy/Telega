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

    override func draw(_ rect: CGRect) {
        clipsToBounds = true
        layer.cornerRadius = frame.size.height / 2
        super.draw(rect)
    }
}
