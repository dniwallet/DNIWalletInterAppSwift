//
//  CheckDNIWalletVC.swift
//  DNIWalletInterAppSwift
//
//  Created by DNI Wallet on 22/4/23.
//  Copyright © DNIWallet,S.L. All rights reserved.
//

import UIKit
import IAC_DNIWallet

// Proyecto de ejemplo: Secuware:Fotocopia = "000000001:000002000"
let secuwareOID = "000000001"
let secuware_photocopyOID = "000002000"

//- MARK: Utilidades
/// Obtiene los segundos desde 1970 (epoch)
var epoch: Int {
    return Int(NSDate().timeIntervalSince1970 * 1000)
}

class CheckDNIWalletVC: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //- MARK: Campos de texto para especificar OrganizationID, ProcessID y ExpressID
    @IBOutlet weak var orgIDTextField: UITextField!
    @IBOutlet weak var procIDTextField: UITextField!
    @IBOutlet weak var extIDTextField: UITextField!
    @IBOutlet weak var dniTextField: UITextField!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Here, you can define the action to be taken when the return key is pressed
        // For example, you can dismiss the keyboard:
        if textField == orgIDTextField {
            procIDTextField.becomeFirstResponder()
        } else if textField == procIDTextField {
            extIDTextField.becomeFirstResponder()
        } else if textField == extIDTextField {
            dniTextField.becomeFirstResponder()
        } else {
            dniTextField.resignFirstResponder()
        }
        
        // Or you can perform another action, like moving to the next field
        // or submitting a form.
        return true
    }
    
    //- MARK: Comprobación de los campos de texto
    // Funcion para comprobar que los campos OrganizationID y ProcessID son numericos y de 9 digitos
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle backspace/delete
        guard !string.isEmpty else {
            // Backspace detected, allow text change, no need to process the text any further
            return true
        }
        
        if textField == extIDTextField {

            // Input Validation. External ID could be alphanumeric

            // Length Processing
            // Need to convert the NSRange to a Swift-appropriate type
            if let text = textField.text, let range = Range(range, in: text) {
                let proposedText = text.replacingCharacters(in: range, with: string)
                // Check proposed text length does not exceed max character count
                guard proposedText.count <= 119 else {
                    // Present alert if pasting text
                    // easy: pasted data has a length greater than 1; who copy/pastes one character?
                    if string.count > 1 {
                        // Pasting text, present alert so the user knows what went wrong
                        Alert(Title: "Error in text field", Message: "Failed to paste text. An external ID has a maximum of 119 characters.")
                    }
                    // Character count exceeded, disallow text change
                    return false
                }
            }
            // Allow text change
            return true
            
        }
        if textField == dniTextField {

            // Input Validation. DNI could be alphanumeric

            // Length Processing
            // Need to convert the NSRange to a Swift-appropriate type
            if let text = textField.text, let range = Range(range, in: text) {
                let proposedText = text.replacingCharacters(in: range, with: string)
                // Check proposed text length does not exceed max character count
                guard proposedText.count <= 9 else {
                    // Present alert if pasting text
                    // easy: pasted data has a length greater than 1; who copy/pastes one character?
                    if string.count > 1 {
                        // Pasting text, present alert so the user knows what went wrong
                        Alert(Title: "Error in text field", Message: "Failed to paste text. An DNI number has a maximum of 9 characters.")
                    }
                    // Character count exceeded, disallow text change
                    return false
                }
            }
            // Allow text change
            return true
            
        }
        else {
        
            // Input Validation
            // Prevent invalid character input, if keyboard is numberpad
            if textField.keyboardType == .numberPad {
                // Check for invalid input characters
                if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
                    // Present alert so the user knows what went wrong
                    // Invalid characters detected, disallow text change
                }
                else {
                    Alert(Title: "Error in identifier", Message: "Este campo sólo admite un número de 9 digitos")
                    return false
                }
            }

            // Length Processing
            // Need to convert the NSRange to a Swift-appropriate type
            if let text = textField.text, let range = Range(range, in: text) {
                let proposedText = text.replacingCharacters(in: range, with: string)
                // Check proposed text length does not exceed max character count
                guard proposedText.count <= 9 else {
                    // Present alert if pasting text
                    // easy: pasted data has a length greater than 1; who copy/pastes one character?
                    if string.count > 1 {
                        // Pasting text, present alert so the user knows what went wrong
                        Alert(Title: "Error in text field", Message: "Failed to paste text. Only 9 characters are allowed.")
                    }
                    // Character count exceeded, disallow text change
                    return false
                }
            }
            // Allow text change
            return true
        }
    }

    //- MARK: Actions de los botones
    
    /// Acción cuando se pulsa el botón checkDNIWallet
    @IBAction func checkDNIWalletButton(_ sender: UIButton) {
        if DNIWalletPlusIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet+ is installed", Message: "DNI Wallet+ is installed on this iPhone.")
        }
        else if DNIWalletBasicIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet is installed", Message: "DNI Wallet is installed on this iPhone.")
        }
        else {
            Alert(Title: "DNI Wallet is not installed", Message: "This iPhone does not have DNI Wallet or DNI Wallet+ installed")
        }
    }
    
    /// Función más simple que la anterior. DNIWalletIACClient se encarga primero verificar si existe DNI Wallet+ y si no existe, DNI Wallet
    @IBAction func checkDNIWalletButtonSimpler(_ sender: UIButton) {
        if DNIWalletIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet is installed", Message: "DNI Wallet is installed on this iPhone.")
        }
        else {
            Alert(Title: "DNI Wallet is not installed", Message: "This iPhone does not have DNI Wallet or DNI Wallet+ installed")
        }
    }
    
    /// Acción cuando se pulsa el botón launchDNIWallet
    @IBAction func launchDNIWalletButton(_ sender: UIButton) {
        // Comprueba que hay conexión a Internet
        if !CheckInternet.Connection() {
            Alert(Title: "There is no internet connection", Message: "The iPhone is not connected to the Internet")
            return
        }

        // Comprueba que DNI Wallet está instalado. Si no lo está sugiere instalarla.
        // Se puede cambiar la llamada a AskInstall por una pantalla mas descriptiva para ayudar a la instalación
        let client = DNIWalletIACClient()
        if !client.isAppInstalled() {
            AskInstall(Title: "DNI Wallet is not installed", Message: "This iPhone does not have DNI Wallet installed")
            return
        }

        var extID = ""
        if let id = extIDTextField.text, id.count <= 119 {
            extID = id
        }

        var dni = ""
        if let id = dniTextField.text, id.count == 9 {
            dni = id
        }

        if let orgID = orgIDTextField.text, orgID.count == 9,
           let procID = procIDTextField.text, procID.count == 9 {
            
            // Guarda los valores para las siguientes veces
            UserDefaults.standard.set(orgID, forKey: "orgid_preference")
            UserDefaults.standard.set(procID, forKey: "procid_preference")
            UserDefaults.standard.set(extID, forKey: "extid_preference")
            UserDefaults.standard.set(dni, forKey: "dni_preference")

            // Ejecuta el proceso definido por orgID y procID
            client.runProcess(organizationID: orgID, processID: procID, externalID: extID, dni: dni, params:[:], handler: { result in
                // NOTA IMPORTANTE:
                // Esta aplicacion de ejemplo no utiliza enlaces universales
                // El resultado del proceso DNI Wallet en tu App se debe obtener en el callback del proceso (enlace universal de tu app)
                switch result {
                case .success(let data):
                    print("OK: \(data)")
                case .cancelled:
                    print("Cancelled")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem) {
        // Dismiss the keyboard
        if orgIDTextField.isFirstResponder {
            procIDTextField.becomeFirstResponder()
        } else if procIDTextField.isFirstResponder {
            extIDTextField.becomeFirstResponder()
        } else if extIDTextField.isFirstResponder {
            dniTextField.becomeFirstResponder()
        }
    }
    
    func scrollToView(view: UIView, animated: Bool) {
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollToView(view: textField, animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            // Calculate the content inset to make the focused item visible
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            
            // Apply the content inset to your UIScrollView
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the content inset when the keyboard is hidden
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        orgIDTextField.delegate = self
        procIDTextField.delegate = self
        extIDTextField.delegate = self
        dniTextField.delegate = self

        // Read values used last time. If none, then use "Secuware:Photocopy" project
        orgIDTextField.text = secuwareOID
        procIDTextField.text = secuware_photocopyOID
        extIDTextField.text = ""
        dniTextField.text = ""

        // Enables a Done Button for numeric keyboards
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // Add a flexible space item to push the "Done" button to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        orgIDTextField.inputAccessoryView = toolbar
        procIDTextField.inputAccessoryView = toolbar

        if let orgID = UserDefaults.standard.string(forKey: "orgid_preference"), orgID != "" {
            self.orgIDTextField.text = orgID
        }

        if let procID = UserDefaults.standard.string(forKey: "procid_preference"), procID != "" {
            procIDTextField.text = procID
        }

        if let extID = UserDefaults.standard.string(forKey: "extid_preference"), extID != "" {
            extIDTextField.text = extID
        }

        if let dni = UserDefaults.standard.string(forKey: "dni_preference"), dni != "" {
            dniTextField.text = dni
        }
    }

}

