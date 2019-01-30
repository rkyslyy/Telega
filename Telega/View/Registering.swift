//
//  Registering.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/30/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu

class Registering: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var icon: GIFImageView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("RegisteringXIB", owner: self, options: nil)
        frame = contentView.frame
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
