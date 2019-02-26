//
//  Registering.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/30/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu

class AuthLoading: UIView {

	@IBOutlet var contentView: UIView!
	@IBOutlet weak var icon: GIFImageView!
	@IBOutlet weak var label: UILabel!

	func showResultWith(
		success: Bool,
		andMessage message: String,
		completion: @escaping () -> ()) {
		UIView.animate(withDuration: 0.2, animations: {
			self.icon.alpha = 0
		}, completion: { (_) in
			self.icon.stopAnimating()
			var image = success
				? UIImage(named: "tick")
				: UIImage(named: "close")
			if message.components(separatedBy: " ")[0] == "Confirm" {
				image = UIImage(named: "envelope")
			}
			let imageView = UIImageView(image: image)
			imageView.frame = CGRect(
				x: self.center.x - 25,
				y: self.icon.frame.origin.y + 30,
				width: 50,
				height: 50)
			imageView.alpha = 0
			self.addSubview(imageView)
			UIView.animate(withDuration: 0.2, animations: {
				imageView.alpha = 1
				self.label.text = message
			}, completion: { (_) in
				if message.components(separatedBy: " ")[0] != "Logged" {
					imageView.shake()
				}
				completion()
			})
		})
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}

	private func customInit() {
		Bundle.main.loadNibNamed("AuthLoadingXIB", owner: self, options: nil)
		frame = contentView.frame
		addSubview(contentView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
