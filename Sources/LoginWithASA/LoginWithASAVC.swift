//
//  File.swift
//  
//
//  Created by Mykola Hrybeniuk on 10.05.2024.
//

import Foundation
import UIKit
import WebKit


struct ErrorReponse {
    let statusCode: Int
    let message: String
}

final class LoginWithASAVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var loader: UIActivityIndicatorView!
    var navigationUrlHandler: ((URLRequest) -> ())?
    var vcFinished: (() -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        webView = .init()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        
        if #available(iOS 13.0, *) {
            loader = .init(style: .medium)
        } else {
            loader = .init(style: .gray)
        }
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .gray
        loader.hidesWhenStopped = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login With ASA"
        
        view.addSubview(webView)
        view.addSubview(loader)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        navigationUrlHandler?(navigationAction.request)
        decisionHandler(.allow)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vcFinished?()
    }
    
}

final class APIService {
    
    func authorise(with params: [String: Any], subscriptionKey: String, apiVersion: String, completionHanlder: @escaping ((URL?, ErrorReponse?) -> Void)) {
        let url = URL(string: "https://openapi.asacore.com/Authentication/Authorization")!
        var request = URLRequest(url: url)
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue(apiVersion, forHTTPHeaderField: "X-ASA-APIVersion")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type" )
        request.httpMethod = "POST"

        let data = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data, let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            
            let statusCode = (dict["status"] as? Int) ?? 99
            let dataDict = dict["data"] as? [String: Any]
            let messageData = dataDict?["message"] as? String ?? "Error parsing login URL."
            
            guard statusCode == 200 else {
                completionHanlder(nil, .init(statusCode: statusCode, message: messageData))
                return
            }
            
            guard let url = URL(string: messageData) else {
                completionHanlder(nil, .init(statusCode: statusCode, message: messageData))
                return
            }
            completionHanlder(url, nil)
        }

        task.resume()
    }
}
