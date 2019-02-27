//
//  PasswordRules.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class PasswordRules: UIView {

  // Outlets
  @IBOutlet var contentView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  private func customInit() {
    Bundle.main.loadNibNamed("PasswordRulesXIB", owner: self, options: nil)
    frame = contentView.frame
    addSubview(contentView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func gotItPressed() {
    UIView.animate(
      withDuration: 0.2,
      animations: { self.alpha = 0 },
      completion: { (_) in self.removeFromSuperview() })
  }
}
