//
//  SecondViewController.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import AVKit
import Gifu

class SettingsVC: UIViewController,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate {

	// Outlets
	@IBOutlet weak var saveBtn: UIBarButtonItem!
	@IBOutlet weak var avatarView: CircleImageView!
	@IBOutlet weak var emailLbl: UILabel!
	@IBOutlet weak var usernameTxtFld: UITextField!
	@IBOutlet weak var logoutBtn: UIButton!

	// Constants
	let pickerController = UIImagePickerController()

	// Variables
	var pickedImage: UIImage?
	var pickedData: Data?

	override func viewDidLoad() {
		super.viewDidLoad()

		let tap = UITapGestureRecognizer(
			target: self,
			action: #selector(hideKeyboard))
		view.addGestureRecognizer(tap)
		pickerController.delegate = self
		pickerController.allowsEditing = false
		pickerController.sourceType = .photoLibrary

		usernameTxtFld.addTarget(
			self,
			action: #selector(controlUsername),
			for: .editingChanged)
	}

	@objc private func hideKeyboard() {
		view.endEditing(true)
	}

	override func viewWillAppear(_ animated: Bool) {
		emailLbl.text = DataService.instance.email
		usernameTxtFld.text = DataService.instance.username
		if pickedImage == nil {
			let data = Data(base64Encoded: DataService.instance.userAvatar!)
			let image = UIImage(data: data!)
			avatarView.image = image
			avatarView.backgroundColor = .darkGray
		} else {
			avatarView.image = pickedImage
		}
		if UIApplication.shared.statusBarFrame.width > 450 {
			avatarView.layer.cornerRadius = 150
		} else {
			avatarView.layer.cornerRadius = 60
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		pickedImage = nil
		pickedData = nil
	}

	@IBAction func changeAvatarPressed(_ sender: Any) {
		UIView.animate(withDuration: 0.2) { self.logoutBtn.alpha = 0 }
		let alert = UIAlertController(
			title: "Choose source",
			message: nil,
			preferredStyle: .actionSheet)
		let pickFromLibrary = UIAlertAction(
			title: "Take from photo library",
			style: .default) { (_) in
				UIView.animate(withDuration: 0.2) { self.logoutBtn.alpha = 1 }
				if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
					self.pickerController.sourceType = .photoLibrary
					self.present(
						self.pickerController,
						animated: true,
						completion: nil)
				}
		}
		let takePhoto = UIAlertAction(
			title: "Take photo with camera",
			style: .default) { (_) in
				UIView.animate(withDuration: 0.2) { self.logoutBtn.alpha = 1 }
				AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
					if response {
						DispatchQueue.main.async {
							if UIImagePickerController.isSourceTypeAvailable(.camera) {
								self.pickerController.sourceType = .camera
								self.present(
									self.pickerController,
									animated: true,
									completion: nil)
							} else {
								let alert = UIAlertController(
									title: "Sorry",
									message: "Camera is not available on this device",
									preferredStyle: .alert)
								alert.addAction(UIAlertAction(
									title: "Ok",
									style: .default,
									handler: nil))
								self.present(alert, animated: true, completion: nil)
							}
						}
					}
				}
		}
		alert.addAction(pickFromLibrary)
		alert.addAction(takePhoto)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)  { (_) in
			UIView.animate(withDuration: 0.2) { self.logoutBtn.alpha = 1 }
		})
		present(alert, animated: true, completion: nil)
	}

	@IBAction func savePressed(_ sender: Any) {
		saveBtn.isEnabled = false
		view.endEditing(true)

		let base64 = pickedData?.base64EncodedString() ??
								 avatarView.image!.jpeg(.medium)?.base64EncodedString()
		let darkView = UIView(frame: view.bounds)
		darkView.alpha = 0
		darkView.backgroundColor = UIColor(white: 0, alpha: 0.7)
		let ripple = GIFImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
		ripple.center = view.center
		ripple.animate(withGIFNamed: "ripple")
		view.addSubview(darkView)
		view.addSubview(ripple)
		UIView.animate(withDuration: 0.2) { darkView.alpha = 1 }
		TelegaAPI.editProfileWith(
			username: usernameTxtFld.text!,
			andAvatar: base64!) {
				UIView.animate(withDuration: 0.2, animations: {
					darkView.alpha = 0
					ripple.alpha = 0
				}, completion: { (_) in
					darkView.removeFromSuperview()
					ripple.removeFromSuperview()
					self.saveBtn.isEnabled = true
			})
		}
	}

	@IBAction func logoutPressed(_ sender: Any) {
		DataService.instance.logout()
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let authVC = storyboard.instantiateViewController(withIdentifier: "authVC")
		present(authVC, animated: true, completion: nil)
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
		) {
		if let pickerImage = info[.originalImage] as? UIImage {
			let data = pickerImage.jpeg(.medium)
			let image = UIImage(data: data!)
			pickedImage = image!
			pickedData = data!
			picker.dismiss(animated: true, completion: nil)
		}
	}

	@IBAction func changePasswordBtnPressed(_ sender: Any) {
		performSegue(withIdentifier: "toChangePassword", sender: nil)
	}

	func hideLogoutBtn() {
		UIView.animate(withDuration: 0.2) {
			self.logoutBtn.alpha = 0
		}
	}

	@objc private func controlUsername() {
		if usernameTxtFld
			.text?
			.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			saveBtn.isEnabled = false
		} else {
			saveBtn.isEnabled = true
		}
	}
}
