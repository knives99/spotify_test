//
//  AuthViewController.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import UIKit
import WebKit

class AuthViewController: UITabBarController, WKNavigationDelegate {
    
    private let webView:WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    public var completionHandler:((Bool)-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign in"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else{return}
        webView.load(URLRequest(url: url))

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {return}
        
        //Exchange the code for access token 當客戶登入成功可得到一個code 藉由這個code可得到token
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else{return}
        print("code \(code)")
        webView.isHidden = true
        
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self]success in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
    

    

}
