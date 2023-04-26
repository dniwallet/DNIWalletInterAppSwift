//
//  CheckInternetVC.swift
//  DNIWalletInterAppSwift
//
//  Created by DNI Wallet on 22/4/23.
//  Copyright © DNIWallet,S.L. All rights reserved.
//

import UIKit
import IAC_DNIWallet

class CheckInternetVC: UIViewController {
    
    /// Accion cuando se pulsa el botón checkInternet
    @IBAction func checkInternetButton(_ sender: UIButton) {
        if CheckInternet.Connection() {
            Alert(Title: "Hay conexión", Message: "El iPhone está conectado a Internet")
        }
        else{
            Alert(Title: "No hay conexión", Message: "El iPhone no está conectado a Internet")
        }
    }
    
}

