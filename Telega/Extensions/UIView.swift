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
}

