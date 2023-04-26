# DNI Wallet Inter App Swift
Ejemplo de App iOS en Swift que interacciona con la App DNI Wallet o DNI Wallet+

## Introducción

* DNI Wallet utiliza el esquema **x-callback-dniwallet://**
* DNI Wallet+ utiliza el esquema **x-callback-dniwalletplus://**

* Importa con SPM el paquete IAC_DNIWallet_Swift(https://github.com/dniwallet/IAC_DNIWallet_Swift) 

* IAC_DNIWallet_Swift se encarga de lanzar DNI Wallet para ejecutar un proceso. El callback del proceso deberia ser un enlace universal a tu app a la que se le pasa el token JWE con los datos solicitados a DNI Wallet 


## Comprobar si están instaladas las apps DNI Wallet o DNI Wallet+
* Para poder comprobar si la app DNI Wallet o DNI Wallet+ están instaladas es necesario poder consultar los dos esquemas.
* Para ello añade a tu Info.plist:
    ```xml
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>x-callback-dniwalletplus</string>
        <string>x-callback-dniwallet</string>
    </array>
    ```
* En CheckDNIWalletVC está el ejemplo de consulta de si DNI Wallet está instalada (función **checkDNIWalletButton**) 
    ```swift
    import IAC_DNIWallet
    
    /// Función que comprueba si DNI Wallet está instalada. DNIWalletIACClient se encarga de verificar si está instalada la app DNI Wallet+ y si no está, verifica DNI Wallet
    @IBAction func checkDNIWalletButtonSimpler(_ sender: UIButton) {
        if DNIWalletIACClient().isAppInstalled() {
            Alert(Title: "DNI Wallet está instalado", Message: "DNI Wallet está instalado en este iPhone")
        }
        else {
            Alert(Title: "DNI Wallet no está instalado", Message: "Este iPhone no tiene instalado DNI Wallet ni DNI Wallet+")
        }
    }
    ```

## Lanzar la app DNI Wallet desde otra app para ejecutar un proceso
    
#### Función launchDNIWalletButton
* En launchDNIWalletVC está el ejemplo que 
    * comprueba que hay conexión a Internet
    * verifica que la App DNI Wallet está instalada 
    * lanza un proyecto DNI Wallet 

```swift

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
        
        // Ejecuta el proceso definido por orgID y procID. 
        client.runProcess(organizationID: orgID, processID: procID, params:[:], handler: { result in
            // NOTA IMPORTANTE: 
            // Esta aplicacion de ejemplo no utiliza enlaces universales
            // El resultado del proceso DNI Wallet se obtiene en el callback del proceso (enlace universal de tu app)
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

```

## Lanzar la app DNI Wallet desde una página Web
* Para lanzar un proceso se puede utilizar el esquema dniwallet (se utiliza en los DNIQR insertados en páginas Web)
    * **dniwallet://p/epoch:orgID:procID** 
    * donde
        * **epoch** es el numero de segundos desde 1970 (Unix epoch) y se utiliza para indicar cuando se lanza el proyecto
        * **orgID** es el identificador de organización
        * **procID** es el identificador de proceso
* Ejemplos:
    * **dniwallet://p/1682208115283:000000001:000002000**

## Documentación
* [Apple: Defining a custom URL scheme for your app](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app) 


## License

MIT License

Copyright (c) 2023 DNI Wallet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
