//
//  MessageCell.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/8/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var leftCon: NSLayoutConstraint!
    @IBOutlet weak var rightCon: NSLayoutConstraint!
    @IBOutlet weak var messageText: UILabel!
    
    // Variables
    var lanchor: NSLayoutConstraint!
    var ranchor: NSLayoutConstraint!
}
