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
    
    func dismissSelfWith(success: Bool, completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.2, animations: {
            self.icon.alpha = 0
        }, completion: { (_) in
            self.icon.stopAnimating()
            let image = success ? UIImage(named: "tick") : UIImage(named: "close")
            let imageView = UIImageView(image: image)
            let label = success ? "Done!" : "Something went wrong"
            imageView.frame = self.icon.frame
            imageView.alpha = 0
            self.addSubview(imageView)
            UIView.animate(withDuration: 0.2, animations: {
                imageView.alpha = 1
                self.label.text = label
            }, completion: { (_) in
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
