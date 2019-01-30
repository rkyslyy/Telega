//
//  LoginVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu

class AuthVC: UIViewController {

    // Outlets
    @IBOutlet weak var backgroundTop: GIFImageView!
    @IBOutlet weak var window: RoundedView!
    @IBOutlet weak var emailTxtFld: CustomPlaceholderTF!
    @IBOutlet weak var passwordTxtFld: CustomPlaceholderTF!
    @IBOutlet weak var confirmPasswordTxtFld: CustomPlaceholderTF!
    @IBOutlet weak var confirmPassYConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameTxtFld: CustomPlaceholderTF!
    @IBOutlet weak var usernameTxtFldYConstraint: NSLayoutConstraint!
    @IBOutlet weak var windowYConstraint: NSLayoutConstraint!
    @IBOutlet weak var windowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var accntCreateToggleBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    // Variables
    var editingText = false
    var creatingAccnt = false
    var loadingMask : AuthLoading!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackground()
        initFields()
        createTap()
        if view.bounds.size.width < 375 {
            stackView.spacing = 10
        }
    }
    
    private func initBackground() {
        backgroundTop.animate(withGIFNamed: "black")
    }
    
    private func createTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func initFields() {
        emailTxtFld.delegate = self
        passwordTxtFld.delegate = self
        confirmPasswordTxtFld.delegate = self
        usernameTxtFld.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func createAccntTogglePressed(_ sender: Any) {
        creatingAccnt = !creatingAccnt
        let newToggleTitle = creatingAccnt ? "I already have an account" : "Dont have an account?"
        let newDoneTitle = creatingAccnt ? "Register" : "Login"
        let sign : CGFloat = creatingAccnt ? 1 : -1
        self.windowHeightConstraint.constant += 111 * sign
        UIView.animate(withDuration: 0.2, animations: {
            self.windowYConstraint.constant -= 20 * sign
            self.window.frame.origin.y -= 20 * sign
            self.confirmPasswordTxtFld.frame.origin.y += 32 * sign
            self.confirmPassYConstraint.constant += 47 * sign
            self.usernameTxtFld.frame.origin.y += 79 * sign
            self.usernameTxtFldYConstraint.constant += 94 * sign
            self.accntCreateToggleBtn.setTitle(newToggleTitle, for: .normal)
            self.doneBtn.setTitle(newDoneTitle, for: .normal)
            self.view.layoutIfNeeded()
        })
        if !creatingAccnt {
            confirmPasswordTxtFld.text = ""
            usernameTxtFld.text = ""
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if creatingAccnt {
            view.endEditing(true)
            guard let credentials = getCredentials() else { return }
            let email = credentials.email
            let password = credentials.password
            let username = credentials.username
            if creatingAccnt {
                accntCreateToggleBtn.sendActions(for: .touchUpInside)
            }
            createLoadingMask()
            AuthService.instanse.registerUserWith(email: email,
                                                  password: password,
                                                  username: username) { (success) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.loadingMask.icon.alpha = 0
                }, completion: { (_) in
                    self.loadingMask.icon.stopAnimating()
                    let image = success ? UIImage(named: "tick") : UIImage(named: "close")
                    let imageView = UIImageView(image: image)
                    let label = success ? "Done!" : "Something went wrong"
                    imageView.frame = self.loadingMask.icon.frame
                    imageView.alpha = 0
                    self.loadingMask.addSubview(imageView)
                    UIView.animate(withDuration: 0.2, animations: {
                        imageView.alpha = 1
                        self.loadingMask.label.text = label
                    }, completion: { (_) in
                        if success {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.loadingMask.alpha = 0
                                    self.toggleWindowContents(hide: false)
                                }, completion: { (_) in
                                    self.loadingMask.removeFromSuperview()
                                })
                            })
                        } else {
                            
                        }
                    })
                })
            }
        }
    }
    
    private func getCredentials() -> (email: String, password: String, username: String)? {
        guard let email =       emailTxtFld.text,
                                emailTxtFld.text != ""
                                else { return nil }
        guard let password =    passwordTxtFld.text,
                                passwordTxtFld.text != "",
                                passwordTxtFld.text == confirmPasswordTxtFld.text
                                else { return nil }
        guard let username =    usernameTxtFld.text,
                                usernameTxtFld.text != ""
                                else { return nil }
        return (email: email,
                password: password,
                username: username)
    }
    
    private func presentAlertWith(title: String, message: String, andButtonTitle btnTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: btnTitle, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func toggleWindowContents(hide: Bool) {
        let state : CGFloat = hide ? 0 : 1
        self.usernameTxtFld.alpha = state
        self.confirmPasswordTxtFld.alpha = state
        self.emailTxtFld.alpha = state
        self.passwordTxtFld.alpha = state
        self.accntCreateToggleBtn.alpha = state
        self.doneBtn.alpha = state
    }
    
}

extension AuthVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !editingText {
            UIView.animate(withDuration: 0.2) {
                self.window.frame.origin.y -= 80
                self.windowYConstraint.constant -= 80
            }
        }
        editingText = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !emailTxtFld.isFirstResponder &&
            !passwordTxtFld.isFirstResponder &&
            !confirmPasswordTxtFld.isFirstResponder &&
            !usernameTxtFld.isFirstResponder {
            UIView.animate(withDuration: 0.2) {
                self.window.frame.origin.y += 80
                self.windowYConstraint.constant += 80
            }
        }
        editingText = false
    }
}

extension AuthVC {
    
    private func createLoadingMask() {
        self.loadingMask = AuthLoading(frame: window.frame)
        self.loadingMask.frame.size.width = window.frame.width
        self.loadingMask.icon.animate(withGIFNamed: "ripple")
        self.loadingMask.alpha = 0
        window.addSubview(self.loadingMask)
        UIView.animate(withDuration: 0.2) {
            self.toggleWindowContents(hide: true)
            self.loadingMask.alpha = 1
        }
    }
    
}
