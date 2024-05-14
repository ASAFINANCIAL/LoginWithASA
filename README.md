Getting started

The SDK can be add with Swift Package Manager.
Check the documentation.
https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app

Here small example how you can use it in your app.

```swift
class ViewController: UIViewController, LoginWithASAUIDelegate {

    @IBAction func tapOnLoginWithASA(_ sender: Any) {
        let login = LoginWithASA(config: .init(subscriptionKey: "key",
                                               applicationCode: "code",
                                               authorizationKey: "authKey",
                                               asaFintechCode: "fintechCode",
                                               apiVersion: "1.07"))

// uiDelegate is not mandatory, It can be used wihout it but SDK will show the screen with LoginWithASA modally.
// If uiDelegate is used you need to implement functions below which gives ability to show the screen where it is more suitable for you.
 
        login.start(uiDelegate: self, successHandler: { data in
            // If success here in data model berearToken will be existed and all needed information for further work with OpenAPI.
            print(data)
        }, errorHandler: {
            print($0)
        })
    }

    // LoginWithASAUIDelegate Protocol
    func present(loginWithASAVC: UIViewController) {
        present(loginWithASAVC, animated: true)
    }

    func finshed(loginWithASAVC: UIViewController) {
        loginWithASAVC.dismiss(animated: true)
    }

}
```
