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
            Alert(Title: "There is an internet connection", Message: "The iPhone is connected to the Internet")
        }
        else{
            Alert(Title: "There is no internet connection", Message: "The iPhone is not connected to the Internet")
        }
    }
    
}

