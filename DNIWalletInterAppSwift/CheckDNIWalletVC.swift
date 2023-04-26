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
let secuware_fotocopiaOID = "000002000"

//- MARK: Utilidades
/// Obtiene los segundos desde 1970 (epoch)
var epoch: Int {
    return Int(NSDate().timeIntervalSince1970 * 1000)
}

class CheckDNIWalletVC: UIViewController, UITextFieldDelegate {
    
    //- MARK: Campos de texto para especificar OrganizationID y ProcessID
    @IBOutlet weak var orgIDTextField: UITextField!
    @IBOutlet weak var procIDTextField: UITextField!

    //- MARK: Comprobación de los campos de texto
    // Funcion para comprobar que los campos OrganizationID y ProcessID son numericos y de 9 digitos
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle backspace/delete
        guard !string.isEmpty else {
            // Backspace detected, allow text change, no need to process the text any further
            return true
        }

        // Input Validation
        // Prevent invalid character input, if keyboard is numberpad
        if textField.keyboardType == .numberPad {
            // Check for invalid input characters
            if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
                // Present alert so the user knows what went wrong
                // Invalid characters detected, disallow text change
            }
            else {
                Alert(Title: "Error en identificador", Message: "Este campo sólo admite un número de 9 digitos")
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
                    Alert(Title: "Error en campo de texto", Message: "Ha fallado pegar texto. Sólo pueden ser 9 digitos")
                }
                // Character count exceeded, disallow text change
                return false
            }
        }
        // Allow text change
        return true
    }
    
    //- MARK: Actions de los botones
    
    /// Accion cuando se pulsa el botón checkDNIWallet
    @IBAction func checkDNIWalletButton(_ sender: UIButton) {
        if DNIWalletPlusIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet+ está instalado", Message: "DNI Wallet+ está instalado en este iPhone")
        }
        else if DNIWalletBasicIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet está instalado", Message: "DNI Wallet está instalado en este iPhone")
        }
        else {
            Alert(Title: "DNI Wallet no está instalado", Message: "Este iPhone no tiene instalado DNI Wallet ni DNI Wallet+")
        }
    }
    
    /// Funcion mas simple que la anterior. DNIWalletIACClient se encarga primero verificar si existe DNI Wallet+ y si no existe, DNI Wallet
    @IBAction func checkDNIWalletButtonSimpler(_ sender: UIButton) {
        if DNIWalletIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet está instalado", Message: "DNI Wallet está instalado en este iPhone")
        }
        else {
            Alert(Title: "DNI Wallet no está instalado", Message: "Este iPhone no tiene instalado DNI Wallet ni DNI Wallet+")
        }
    }
    
    /// Accion cuando se pulsa el botón launchDNIWallet
    @IBAction func launchDNIWalletButton(_ sender: UIButton) {
        // Comprueba que hay conexión a Internet
        if !CheckInternet.Connection() {
            Alert(Title: "No hay conexión", Message: "El iPhone no está conectado a Internet")
            return
        }

        // Comprueba que DNI Wallet está instalado. Si no lo está sugiere instalarla.
        // Se puede cambiar la llamada a AskInstall por una pantalla mas descriptiva para ayudar a la instalación
        let client = DNIWalletIACClient()
        if !client.isAppInstalled() {
            AskInstall(Title: "DNI Wallet no está instalado", Message: "DNI Wallet no está instalado en este iPhone")
            return
        }

        if let orgID = orgIDTextField.text, orgID.count == 9,
           let procID = procIDTextField.text, procID.count == 9 {
            
            // Guarda los valores para las siguientes veces
            UserDefaults.standard.set(orgID, forKey: "orgid_preference")
            UserDefaults.standard.set(procID, forKey: "procid_preference")
            
            // Ejecuta el proceso definido por orgID y procID
            client.runProcess(organizationID: orgID, processID: procID, params:[:], handler: { result in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgIDTextField.delegate = self
        procIDTextField.delegate = self

        /// Lee los valores orgID y procID utilizados por ultima vez. Si no hay ninguno, usa el proyecto Secuware:Fotocopia
        self.orgIDTextField.text = secuwareOID
        self.procIDTextField.text = secuware_fotocopiaOID

        if let orgID = UserDefaults.standard.string(forKey: "orgid_preference"), orgID != "" {
            self.orgIDTextField.text = orgID
        }

        if let procID = UserDefaults.standard.string(forKey: "procid_preference"), procID != "" {
            self.procIDTextField.text = procID
        }
    }

}

