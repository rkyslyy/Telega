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
    
    // Variables
    var table: UITableView!
    var indexPath: IndexPath!
    var confirmed: Bool!
    var requestIsMine: Bool!
    var contactID: String!
    var gif: GIFImageView!
    
    func setupStatus(confirmed: Bool, requestIsMine: Bool) {
        self.confirmed = confirmed
        self.requestIsMine = requestIsMine
        let image = requestIsMine ? UIImage(named: "hourglass") : UIImage(named: "green_tick")
        statusBtn.setImage(image, for: .normal)
        if !confirmed {
           setupAnimations()
        } else {
            statusBtn.setImage(nil, for: .normal)
        }
    }
    
    @objc private func setupAnimations() {
        layer.removeAllAnimations()
        if requestIsMine {
            statusBtn.isUserInteractionEnabled = false
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.statusBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }, completion: nil)
        } else {
            statusBtn.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.statusBtn.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: nil)
        }
    }
    
    @IBAction func statusBtnPressed(_ sender: Any) {
        statusBtn.layer.removeAllAnimations()
        if !confirmed && !requestIsMine {
            statusBtn.isUserInteractionEnabled = false
            statusBtn.setImage(nil, for: .normal)
            TelegaAPI.instanse.acceptFriendRequestFrom(id: contactID) {
                self.table.reloadRows(at: [self.indexPath], with: .fade)
            }
            gif = GIFImageView(frame: statusBtn.frame)
            gif.animate(withGIFNamed: "ripple")
            self.contentView.addSubview(gif)
        }
    }
}

extension CALayer {
    func pause() {
        let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
        self.speed = 0.0
        self.timeOffset = pausedTime
    }
    
    func resume() {
        let pausedTime: CFTimeInterval = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}
