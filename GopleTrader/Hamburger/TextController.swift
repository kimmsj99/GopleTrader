//
//  TextController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 24..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

class TextController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    let backBtn = UIButton()
    let subHamburgerBtn = UIButton()
    let sTitle = UILabel()
    
//    let id = UserDefaults.standard.object(forKey: "ID") as! String
//    let pw = UserDefaults.standard.object(forKey: "PW") as! String

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let config = WKWebViewConfiguration()
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false

        var url = ""
        
        if UserDefaults.standard.object(forKey: "text") != nil {
            if let text = UserDefaults.standard.object(forKey: "text") as? String {
                if text == "service" {
                    createNavigation(title: "서비스 이용약관", backColor: UIColor.white, textColor: textColor, backImage: #imageLiteral(resourceName: "back"))
                    url = domain + serviceURL
                } else if text == "privacy" {
                    createNavigation(title: "개인정보 처리 방침", backColor: UIColor.white, textColor: textColor, backImage: #imageLiteral(resourceName: "back"))
                    url = domain + privacyURL
                }
            }
        }
        
        let request = URLRequest(url: URL(string : url)!)
        wkWebView.load(request)
        print("\(wkWebView.url!) 실행")
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            wkWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant : 15).isActive = true
        } else {
            wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 15).isActive = true
        }
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

extension TextController {
    func createNavigation(title: String, backColor: UIColor, textColor: UIColor, backImage: UIImage) {
        var tmpView = UIView()
        
        if UIScreen.main.nativeBounds.height == 2436 {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0 ))
        } else {
            tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
        }
        
        tmpView.backgroundColor = backColor
        self.navigationController?.view.addSubview(tmpView)
        
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 59)))
        viewNavBar.backgroundColor = backColor
        
        backBtn.setImage(backImage, for: .normal)
        backBtn.frame = CGRect(x: 5, y: 12, width: 47, height: 35)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        let nTitle = UILabel()
        nTitle.text = title
        nTitle.font = UIFont(name: "DaeHan-Bold", size: 20)
        nTitle.textColor = textColor
        nTitle.textAlignment = .center
        nTitle.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: 20)
        nTitle.center.x = self.view.frame.width / 2
        viewNavBar.addSubview(nTitle)
        
        subHamburgerBtn.setImage(#imageLiteral(resourceName: "sub_hamburger"), for: .normal)
        subHamburgerBtn.frame = CGRect(x: self.view.frame.width - 50, y: 14, width: 37, height: 33)
        subHamburgerBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
//        viewNavBar.addSubview(subHamburgerBtn)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func doneBtn(_ sender: UIButton) {
        
        if ((self.presentingViewController as? JoinController) != nil) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
//        if UserDefaults.standard.object(forKey: "push_url") != nil {
//            self.dismiss(animated: true, completion: nil)
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
        UserDefaults.standard.removeObject(forKey: "text")
        UserDefaults.standard.removeObject(forKey: "push_url")
        
    }
}

extension TextController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = { handler in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
}

extension TextController: WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("localStorage.getItem(\"company_login\")") { (result, error) in
            
            if let error = error {
                print(error)
            } else {
                print(result as? String)
            }
            // check if result is what I want
            // if it is what I want, do nothing
            // if not set it
            
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
}
