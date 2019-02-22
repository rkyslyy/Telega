//
//  DarkNavigationVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Alamofire

class DarkNavigationVC: UINavigationController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
