//
//  ContactCell.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/5/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu

class ContactCell: UITableViewCell {

	// Outlets
	@IBOutlet weak var avatarView: CircleImageView!
	@IBOutlet weak var usernameLbl: UILabel!
	@IBOutlet weak var emailLbl: UILabel!
	@IBOutlet weak var statusBtn: UIButton!
	@IBOutlet weak var unreadStatusImgView: UIImageView!

	// Variables
	var table: UITableView!
	var indexPath: IndexPath!
	var confirmed: Bool!
	var requestIsMine: Bool!
	var contactID: String!
	var online: Bool!
	var unread: Bool!
	var gif: GIFImageView!

	func setupStatus(
		confirmed: Bool,
		requestIsMine: Bool,
		online: Bool,
		unread: Bool
		) {
		self.confirmed = confirmed
		self.requestIsMine = requestIsMine
		let image = requestIsMine ? UIImage(named: "hourglass")
															: UIImage(named: "green_tick")
		statusBtn.setImage(image, for: .normal)
		if !confirmed {
			setupAnimations()
			unreadStatusImgView.image = nil
		} else {
			statusBtn.setImage(
				online ? UIImage(
					named: "online")?.resizedImageWithinRect(
						rectSize: CGSize(width: 15, height: 15))
							 : nil,
				for: .normal)
			unreadStatusImgView.image = unread ? UIImage(named: "envelope") : nil
		}
		if UIApplication.shared.statusBarFrame.width > 450 {
			avatarView.layer.cornerRadius = 65
		} else {
			avatarView.layer.cornerRadius = 25
		}
	}

	@objc private func setupAnimations() {
		layer.removeAllAnimations()
		if requestIsMine {
			statusBtn.isUserInteractionEnabled = false
			UIView.animate(
				withDuration: 1.0,
				delay: 0,
				options: [.repeat, .autoreverse, .allowUserInteraction],
				animations: {
					self.statusBtn.transform = CGAffineTransform(
						rotationAngle: CGFloat(Double.pi))
			},
				completion: nil)
		} else {
			statusBtn.isUserInteractionEnabled = true
			UIView.animate(
				withDuration: 0.5,
				delay: 0,
				options: [.repeat, .autoreverse, .allowUserInteraction],
				animations: {
					self.statusBtn.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			},
				completion: nil)
		}
	}

	@IBAction func statusBtnPressed(_ sender: Any) {
		statusBtn.layer.removeAllAnimations()
		if !confirmed && !requestIsMine {
			statusBtn.isUserInteractionEnabled = false
			statusBtn.setImage(nil, for: .normal)
			TelegaAPI.acceptFriendRequestFrom(id: contactID) {
				self.table.reloadRows(at: [self.indexPath], with: .fade)
			}
			gif = GIFImageView(frame: statusBtn.frame)
			gif.animate(withGIFNamed: "ripple")
			self.contentView.addSubview(gif)
		}
	}
}
