// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

public protocol LoginWithASAUIDelegate {
    
    func present(loginWithASAVC: UIViewController)
    
}

public struct LoginWithASAResponse {
    public let asaConsumerCode: String
    public let token: String
    public let expirydatefortoken: String
    public let networth: Double
    public let email: String
    public let asaFintechCode: String
    
    public init(asaConsumerCode: String, token: String, expirydatefortoken: String, networth: Double, email: String, asaFintechCode: String) {
        self.asaConsumerCode = asaConsumerCode
        self.token = token
        self.expirydatefortoken = expirydatefortoken
        self.networth = networth
        self.email = email
        self.asaFintechCode = asaFintechCode
    }
}

public struct Config {
    public let subscriptionKey: String
    public let applicationCode: String
    public let authorizationKey: String
    public let asaFintechCode: String
    public let apiVersion: String
    
    let redirectUrl: String = "https://loginWithAsa/asalogin"
    let redirectFailureUrl: String = "https://loginWithAsa/asaloginfailed"
    
    public init(subscriptionKey: String, applicationCode: String, authorizationKey: String, asaFintechCode: String, apiVersion: String) {
        self.subscriptionKey = subscriptionKey
        self.applicationCode = applicationCode
        self.authorizationKey = authorizationKey
        self.asaFintechCode = asaFintechCode
        self.apiVersion = apiVersion
    }
}

public class LoginWithASA {
    private let config: Config
    private var nav: UINavigationController?
    
    public init(config: Config) {
        self.config = config
    }
    
    public func start(uiDelegate: LoginWithASAUIDelegate? = nil, successHandler: @escaping ((LoginWithASAResponse) -> ()), errorHandler: @escaping ((String) -> ())) {

        let vc = LoginWithASAVC(nibName: nil, bundle: nil)
        vc.loader.startAnimating()
        vc.vcFinished = { self.nav = nil }
        


        
        vc.navigationUrlHandler = { urlRequest in
            guard let url = urlRequest.url else { return }
            
            let components = URLComponents(string: url.absoluteString)
            
            if url.absoluteString.hasPrefix(self.config.redirectUrl),
               let consumerCode = components?.queryItems?.first(where: { $0.name.lowercased() == "asaconsumercode" })?.value,
               let token = components?.queryItems?.first(where: { $0.name.lowercased() == "bearertoken" })?.value,
               let date = components?.queryItems?.first(where: { $0.name.lowercased() == "expirydatefortoken" })?.value,
               let email = components?.queryItems?.first(where: { $0.name.lowercased() == "email" })?.value,
               let asaFintechCode = components?.queryItems?.first(where: { $0.name.lowercased() == "asafintechcode" })?.value {
                
                let networth = components?.queryItems?.first(where: { $0.name.lowercased() == "networth" })?.value ?? "0"
                let networthDouble = Double(networth) ?? 0
                
                successHandler(.init(asaConsumerCode: consumerCode, token: token, expirydatefortoken: date, networth: networthDouble, email: email, asaFintechCode: asaFintechCode))
            }
            if url.absoluteString.hasPrefix(self.config.redirectFailureUrl) {
                self.showApiError(error: .init(statusCode: 0, message: url.absoluteString))
            }
        }
        
        let dic = ["asaFintechCode" : config.asaFintechCode,
                   "applicationCode" : config.applicationCode,
                   "authorizationKey" : config.authorizationKey,
                   "redirectUrl" : config.redirectUrl,
                   "redirectFailureUrl" : config.redirectFailureUrl,
                   "scope" : "openid",
                   "subscriptionKey" : config.subscriptionKey]
        
        APIService().authorise(with: dic, subscriptionKey: config.subscriptionKey, apiVersion: config.apiVersion) { url, error in
            guard let url else {
                if let error {
                    DispatchQueue.main.sync(execute: { self.showApiError(error: error)})
                }
                
                return
            }
            
            DispatchQueue.main.async {
                vc.webView.load(URLRequest(url: url))
                vc.loader.stopAnimating()
            }
        }
        
        guard let uiDelegate else {
            pushVC(vc: vc)
            return
        }
        
        uiDelegate.present(loginWithASAVC: vc)
    }
    
    
    private func pushVC(vc: UIViewController) {
        nav = UINavigationController(rootViewController: vc)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            nav?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        if #available(iOS 13.0, *) {
            vc.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeNavigationRoot))
        } else {
            // Fallback on earlier versions
        }
        if let rootVC = UIApplication.shared.windows.filter{ $0.isKeyWindow }.first?.rootViewController {
            guard let nav = self.nav else {
                return
            }
            
            rootVC.present(nav, animated: true)
        }
    }
    
    private func showApiError(error: ErrorReponse) {
        let alert = UIAlertController(title: "Error", message: error.message + "\nErrorCode \(error.statusCode)", preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel))
        nav?.present(alert, animated: true)
    }
    
    @objc func closeNavigationRoot() {
        nav?.dismiss(animated: true)
        nav = nil
    }
    
}
