//
//  CurrencyViewController.swift
//  ByteCoin
//
//  Created by Andrés Berumen on 30/07/20.
//  Copyright © 2020 The App Brewery. All rights reserved.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    // MARK: Properties
    var currencyManager = CurrencyManager()
    var selectedCurrency1 = ""
    var selectedCurrency2 = ""
    var userAmount: Float = 0.0
    
    // MARK: Outlets
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var fromPickerView: UIPickerView!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var toPickerView: UIPickerView!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Delegates
        fromTextField.delegate = self
        fromPickerView.delegate = self
        fromPickerView.dataSource = self
        toPickerView.delegate = self
        toPickerView.dataSource = self
        currencyManager.delegate = self
        
        // MARK: NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        currencyManager.getCurrency1(currency1: selectedCurrency1, currency2: selectedCurrency2)
    }
    
    
    
    // MARK: - Handle Keyboard
    deinit {
        // Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func handleKeyboardWillChange(notification: Notification) {
        // Here handle the keyboard
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height / 3
        } else {
            view.frame.origin.y = 0
        }
    }
    
}




// MARK: - PickerViewDataSource Extension
extension CurrencyViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyManager.currencyArray.count
    }
    
}




// MARK: - PickerView Delegate Extension
extension CurrencyViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return currencyManager.currencyArray[row]
        } else {
            return currencyManager.currencyArray2[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            selectedCurrency1 = currencyManager.currencyArray[row]
            print(selectedCurrency1)
            fromCurrency.text = selectedCurrency1
        } else {
            selectedCurrency2 = currencyManager.currencyArray2[row]
            print(selectedCurrency2)
            toCurrency.text = selectedCurrency2
        }
        
        if selectedCurrency1 == selectedCurrency2 {
            resultLabel.text = "\(fromTextField.text!).00"
        }
        
        currencyManager.getCurrency1(currency1: selectedCurrency1, currency2: selectedCurrency2)
    }
}




// MARK: - TextField Delegate Extension
extension CurrencyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fromTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currencyManager.getCurrency1(currency1: selectedCurrency1, currency2: selectedCurrency2)
        
        if userAmount >= 0 {
        } else {
            resultLabel.text = "Use only numbers, not: \(fromTextField.text!)"
        }
        
        if let safeAmount = Float(fromTextField.text!) {
            userAmount = safeAmount
        } else {
            userAmount = 0.0
        }
        
        if selectedCurrency1 == selectedCurrency2 {
            resultLabel.text = "\(fromTextField.text!).00"
        }
    }
}




// MARK: - CurrencyManager Delegate Extension
extension CurrencyViewController: CurrencyManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdate(_ currencyManager: CurrencyManager, currencyData: Float) {
        DispatchQueue.main.async {
            let finalPrice = currencyData * self.userAmount
            self.resultLabel.text = String(format: "%.2f", finalPrice)
        }
    }
}
