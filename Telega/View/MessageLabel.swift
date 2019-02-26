//
//  MessageLabel.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/8/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@IBDesignable
class MessageLabel: UILabel {

	override func draw(_ rect: CGRect) {
		clipsToBounds = true
		layer.cornerRadius = 10

		super.draw(rect)
	}

	override func drawText(in rect: CGRect) {
		let insets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
		super.drawText(in: rect.inset(by: insets))
	}

	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + 10 + 10, height: size.height + 10 + 10)
	}

}
