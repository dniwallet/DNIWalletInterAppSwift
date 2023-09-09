# DNI Wallet Inter App Swift
Ejemplo de App iOS en Swift que interacciona con la App DNI Wallet o DNI Wallet+

## Introducción

* Hay 3 maneras de lanzar DNI Wallet para ejecutar su proceso desde su aplicación:
    * Utilizando el paquete IAC_DNIWallet_Swift que permite comprobar si DNI Wallet está instalado:
        * Importa con SPM el paquete IAC_DNIWallet_Swift(https://github.com/dniwallet/IAC_DNIWallet_Swift) 
        * DNI Wallet utiliza el esquema **x-callback-dniwallet://**
        * DNI Wallet+ utiliza el esquema **x-callback-dniwalletplus://**
    * Utilizando un deep link con el esquema **dniwallet://**
    * Utilizando un universal link del tipo **https://dniwallet.com:/p/...**


## Utilizando el paquete IAC_DNIWallet_Swift 

### Comprobar si están instaladas las apps DNI Wallet o DNI Wallet+
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
    ```

#### Función launchDNIWalletButton
* En launchDNIWalletVC está el ejemplo que 
    * comprueba que hay conexión a Internet
    * verifica que la App DNI Wallet está instalada 
    * lanzar un proyecto DNI Wallet 

```swift

@IBAction func launchDNIWalletButton(_ sender: UIButton) {
    
    // Comprueba que hay conexión a Internet
    if !CheckInternet.Connection() {
        Alert(Title: "No hay conexión", Message: "El iPhone no está conectado a Internet")
        return
    }

    // Comprueba que DNI Wallet o DNI Wallet+ está instalado
    if !UIApplication.shared.canOpenURL(dniwalletURL) {
        AskInstall(Title: "DNI Wallet no está instalado", Message: "Este iPhone no tiene instalado DNI Wallet ni DNI Wallet+. ¿Desea instalar DNI Wallet?")
        return
    }

    var url = dniwalletURL
    if let orgID = orgIDTextField.text, orgID.count == 9,
       var procID = procIDTextField.text, procID.count == 9 {
        UserDefaults.standard.set(orgID, forKey: "orgid_preference")
        UserDefaults.standard.set(procID, forKey: "procid_preference")
        if let extID = extIDTextField.text, extID.count <= 119 {
            procID = "\(procID)-\(extID)")!
        }
        var sDNI = ""
        if let dni = dniTextField.text, dni.count == 9 {
            sDNI = ":\(dni)"
        }
        url = URL(string: "dniwallet://p/\(epoch):\(orgID):\(procID)\(sDNI)")!
    }

    let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false,
                UIApplication.OpenExternalURLOptionsKey.eventAttribution: true]
    UIApplication.shared.open(url, options: options, completionHandler: { launched in
        print("launched = \(launched)")
    })
}

```

## Utilizando un deep link 
* Para lanzar un proceso se puede utilizar un deep link con el esquema dniwallet://
    * **dniwallet://p/epoch:orgID:procID?params** 
    * donde
        * **epoch** es el numero de segundos desde 1970 (Unix epoch) y se utiliza para indicar cuando se lanza el proyecto
        * **orgID** es el identificador de organización
        * **procID** es el identificador de proceso
        * **extID** es un identificador externo opcional (para que una organización pase un identificador al proceso) A continuacion del procID separado con un guión.
                    En el ejemplo es ABCDEFGHIJK
        * **dni** es un numero de DNI para seleccion automática cuando hay mas de un DNI en un Wallet. En el ejemplo 99999999R que es el DNI de Carmen Española
        * **params** parametros opcionales que desea pasar a su callback. En la forma param1=value1&param2=value2....
* Ejemplos:
    * **dniwallet://p/1682208115283:000000001:000002000-ABCDEFGHIJK:99999999R**
* Para lanzar ese ejemplo de DeepLink desde su aplicación:
```swift
UIApplication.shared.open(URL(string:"dniwallet://p/1682208115283:000000001:000002000-ABCDEFGHIJK:99999999R")!, completionHandler: { ok in
    print(ok)
})
```                


## Utilizando un universal link 
* Para lanzar un proceso se puede utilizar un universal link 
    * **https://dniwallet.com/p/epoch:orgID:procID?params** 
    * donde
        * **epoch** es el numero de segundos desde 1970 (Unix epoch) y se utiliza para indicar cuando se lanza el proyecto
        * **orgID** es el identificador de organización
        * **procID** es el identificador de proceso
        * **extID** es un identificador externo opcional (para que una organización pase un identificador al proceso). A continuacion del procID separado con un guión.
                    En el ejemplo es ABCDEFGHIJK
        * **dni** es un numero de DNI para seleccion automática cuando hay mas de un DNI en un Wallet. En el ejemplo 99999999R que es el DNI de Carmen Española
        * **params** parametros opcionales que desea pasar a su callback. En la forma param1=value1&param2=value2....
* Ejemplo de UniversalLink:
    * **https://dniwallet.com/p/1682208115283:000000001:000002000-ABCDEFGHIJK:99999999R?codigo=3254&user=67976987**
* Para lanzar ese ejemplo de UniversalLink desde su aplicación:
```swift
UIApplication.shared.open(URL(string:"https://dniwallet.com/p/1682208115283:000000001:000002000-ABCDEFGHIJK:99999999R?codigo=3254&user=67976987")!, completionHandler: { ok in
    print(ok)
})
```                


## Documentación
* [Apple: Defining a custom URL scheme for your app](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app) 
