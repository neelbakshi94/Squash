//
//  ViewController.swift
//  Squash
//
//  Created by Neel Bakshi on 23/01/19.
//  Copyright © 2019 Neel Bakshi. All rights reserved.
//
//  Edited by Jose Cervantes on 10/08/22
//

import UIKit

let CardNumberCount = 16

class ViewController: UIViewController {

	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var makePaymentButton: UIButton!
	@IBOutlet var cardTextFields: [UITextField]!
	@IBOutlet weak var cardLengthInfoLabel: UILabel!
	@IBOutlet weak var numberOfCharLabel: UILabel!
	@IBOutlet weak var startPaymentButton: UIButton!
	private var gradientContainerLayer: CALayer = CALayer()
	private var cardNumber: String = ""

	private func addGradient(with red: CGFloat, green: CGFloat, blue: CGFloat) {
		let initialColor: UIColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
		let finalColor = initialColor.withAlphaComponent(0.5)
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [initialColor.cgColor, finalColor.cgColor]
		//BUG
		//The bug is that the gradient layer's frame is not being set correctly. I'm using bounds in my code
		// The fix is on line 33
		gradientLayer.bounds = self.gradientContainerLayer.bounds
		self.gradientContainerLayer.addSublayer(gradientLayer)
	}

	func setupTextFields() {
		for textField in self.cardTextFields {
			textField.text = ""
			textField.delegate = self
		}
		self.cardTextFields.first?.becomeFirstResponder()
	}

	func getNextTextField(for currentTextField: UITextField) -> UITextField? {
		guard let index = self.cardTextFields.firstIndex(of: currentTextField) else {
			return nil
		}
		let nextIndex = index + 1
		if nextIndex < self.cardTextFields.count {
			return self.cardTextFields[nextIndex]
		}
		return nil
	}

	func getPreviousTextField(for currentTextField: UITextField) -> UITextField? {
		guard let index = self.cardTextFields.firstIndex(of: currentTextField) else {
			return nil
		}
		let previousIndex = index - 1
		if previousIndex >= 0 && previousIndex < self.cardTextFields.count {
			return self.cardTextFields[previousIndex]
		}
		return nil
	}

	@IBAction func startPayment(_ sender: Any) {
		self.cardView.isHidden = false
		self.cardLengthInfoLabel.isHidden = false
		self.gradientContainerLayer.removeFromSuperlayer()
		self.gradientContainerLayer.frame = self.cardView.bounds
		self.cardView.layer.insertSublayer(gradientContainerLayer, at: 0)
		// BUG
		// Start payment button needs to be set to restart payment when the user has clicked on the start payment button once.
		self.addGradient(with: 70, green: 44, blue: 118)
		self.setupTextFields()
	}

	@IBAction func makePayment(_ sender: Any) {
		self.validateCardDetails()
	}

	func validateCardDetails() {
		self.updateCardNumber()
		if self.cardNumber.count != CardNumberCount {
			self.showAlert(with: "Card number invalid")
			return
		}
		self.showAlert(with: "Payment done!")
	}

	func updateCardNumber() {
		self.cardNumber = self.cardTextFields.reduce("", { (nextPartialResult, textField) -> String in
			return nextPartialResult + (textField.text ?? "")
		})
		self.numberOfCharLabel.isHidden = false
		self.numberOfCharLabel.text = "\(self.cardNumber.count)"
		if self.cardNumber.count > 0 {
			self.makePaymentButton.isHidden = false
		} else {
			self.makePaymentButton.isHidden = true
		}
	}

	@IBAction func textfieldValueChanged(_ sender: UITextField) {
		self.updateCardNumber()
	}

	func showAlert(with text: String) {
		let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(okAction)
		self.present(alert, animated: true, completion: nil)
	}
}

extension ViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let currentText = textField.text as NSString? else { return true }
		let newText: String = currentText.replacingCharacters(in: range, with: string)
		if newText.count > 4 {
			let nextTextField = self.getNextTextField(for: textField)
			nextTextField?.text = string
			nextTextField?.becomeFirstResponder()
			return false
		}
		if newText.count == 0 {
			// BUG
			// There are four text fields placed inside a stackview with certain spacing
			// The bug here is that once you've filled the entire card number and no try to delete it, the first character of each text field does not get deleted (try deleting the entire card number once you've filled it).
			// The fix is to check if all the characters have been deleted from the current text field, then set that as the text for the current text field, then get the previous text field and make is the first responder. Fix on breakpoint line 126
			self.getPreviousTextField(for: textField)?.becomeFirstResponder()
			return false
		}
		return true
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.updateCardNumber()
	}
}

