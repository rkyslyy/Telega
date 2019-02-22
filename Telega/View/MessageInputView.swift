//
//  MessageInputView.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/8/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@IBDesignable
class MessageInputView: UITextView {
	
	override func draw(_ rect: CGRect) {
		clipsToBounds = true
		layer.cornerRadius = 10
	}
	
}
