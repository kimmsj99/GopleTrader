//
//  HomeController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

protocol LoginDelegate : class {
    func login(id: String, pw: String)
}

protocol LogoutDelegate : class {
    func logout()
}

protocol WithdrawalDelegate : class {
    func withdraw(id: String, pw: String)
}

class HomeController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var hamburgerMenu: UIButton!
    
    @IBOutlet weak var serviceCenter: UILabel!
    @IBOutlet weak var servicePhone: UILabel!
    
    var wkWebView = WKWebView()
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    var config = WKWebViewConfiguration()
    
    var id = ""
    var pw = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = WKUserContentController()
        controller.add(self, name: "getCompanyInfo")
        controller.add(self, name: "setLogout")
        
        config.userContentController = controller
        
        wkWebView = WKWebView(frame: .zero, configuration:  config)
//        wkWebView = WKWebView(frame: self.view.frame, configuration: config)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = true
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        let attributes = [NSForegroundColorAttributeName : UIColor.init(hex: "FFFFFF"),
                          NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 13
        
        var stringValue = "고객센터"
        var stringValue2 = "02-6207-4486"
        
        let attributeString = NSMutableAttributedString(string: stringValue,
                                                        attributes: attributes)
        let attributeString2 = NSMutableAttributedString(string: stringValue2,
                                                        attributes: attributes)
        
        attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: stringValue.characters.count))
        attributeString2.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: stringValue2.characters.count))
        
        serviceCenter.attributedText = attributeString
        servicePhone.attributedText = attributeString2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.object(forKey: "ID") != nil, UserDefaults.standard.object(forKey: "PW") != nil {
            id = UserDefaults.standard.object(forKey: "ID") as! String
            pw = UserDefaults.standard.object(forKey: "PW") as! String
        }
        
        let token = UserDefaults.standard.object(forKey: "token") as! String
        
        if #available(iOS 11.0, *) {
            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
            request.httpMethod = "POST"
            let postString = "id=\(id)&pw=\(pw)&token=\(token)&device=ios"
            request.httpBody = postString.data(using: .utf8)
            self.wkWebView.load(request)
        } else {
            loginSettingWebView(id: id, pw: pw, token: token)
        }
        
        self.view.addSubview(wkWebView)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func goHamburger(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hamburgerController = storyboard.instantiateViewController(withIdentifier: "HamburgerController")
        self.present(hamburgerController, animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "getCompanyInfo" {
            //여기 들어왔다는 것은 무조건 getCompanyInfo가 없다
            //만약 실행이 안되면
            print(message.body)
            guard let scriptMessage = message.body as? String else {
                basicAlert(target: self, title: "데이터 가져오기 실패", message: "다시 로그인을 해주시기 바랍니다")
                logout()
                return
            }
            
            convertToDictionary(text: scriptMessage)
//            UserDefaults.standard.set("getCompanyInfo", forKey: "getCompanyInfo")
//            UserDefaults.standard.set(scriptMessage, forKey: "getCompanyInfo")
            
            if UserDefaults.standard.object(forKey: "push_url") != nil {
                if let naviVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleController") as? NavigationController {
                    self.present(naviVC, animated: true, completion: nil)
                }
            }
        }
    }
    
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        hamburgerMenu.isUserInteractionEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        hamburgerMenu.isUserInteractionEnabled = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
//        if UserDefaults.standard.object(forKey: "getCompanyInfo") == nil {
        wkWebView.evaluateJavaScript("getCompanyInfo()") { result ,error in
            if let error = error {
                print(error)
            } else {
                print(result as? String)
            }
            
        }
//        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
