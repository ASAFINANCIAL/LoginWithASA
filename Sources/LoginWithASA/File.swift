//
//  File.swift
//  
//
//  Created by Mykola Hrybeniuk on 03.05.2024.
//

import UIKit

//curl --location 'https://openapiqa.asacore.com/Authentication/Authorization' \
//--header 'Ocp-Apim-Subscription-Key: 9ae28108db93416fb44058a4a9a7a503' \
//--header 'X-ASA-APIVersion: 1.07' \
//--header 'Content-Type: application/json' \
//--data '{
//    "asaFintechCode": "12345678",
//    "applicationCode": "2001",
//    "authorizationKey": "l8r/i8btbwBRCAaM2m7c",
//    "redirectUrl": "https://dev.spendpal.com/asalogin",
//    "redirectFailureUrl": "https://dev.spendpal.com/asaloginfailed",
//    "scope": "openid",
//    "subscriptionKey": "9ae28108db93416fb44058a4a9a7a503"
//}'


public struct Config {
    let subscriptionKey: String
}


public class LoginWithASA {
    
    
    private let config: Config
    
    public init(config: Config) {
        self.config = config
    }
    
    
    public func start() {
        let vc = UIViewController(nibName: nil, bundle: nil)
        
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive {
                    let rootVC = ((scene as? UIWindowScene)!.delegate as! UIWindowSceneDelegate).window!!.rootViewController
                    rootVC?.present(vc, animated: true)
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

private class APIService {
    
    
    
    
    
}
