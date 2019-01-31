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
    
    func dismissSelfWith(success: Bool, message: String, completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.2, animations: {
            self.icon.alpha = 0
        }, completion: { (_) in
            self.icon.stopAnimating()
            let image = success ? UIImage(named: "envelope") : UIImage(named: "close")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: self.center.x - 25, y: self.icon.frame.origin.y, width: 50, height: 50)
            imageView.alpha = 0
            self.addSubview(imageView)
            UIView.animate(withDuration: 0.2, animations: {
                imageView.alpha = 1
                self.label.text = message
            }, completion: { (_) in
                imageView.shake()
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

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -7.0, 7.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
