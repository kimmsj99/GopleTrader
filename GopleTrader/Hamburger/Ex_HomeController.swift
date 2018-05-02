//
//  Ex_HomeController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 29..
//  Copyright © 2017년 김민주. All rights reserved.
//

import Foundation
import UIKit

extension HomeController: LoginDelegate{
    func login(id : String, pw: String) {
        
        guard let token = UserDefaults.standard.object(forKey: "token") as? String else {
            return
        }
        
        UserDefaults.standard.set(id, forKey: "ID")
        UserDefaults.standard.set(pw, forKey: "PW")
        
        if #available(iOS 11.0, *) {
            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
            
            print("token : \(token)")
            request.httpMethod = "POST"
            let postString = "id=\(id)&pw=\(pw)&token=\(token)&device=ios"
            request.httpBody = postString.data(using: .utf8)
            self.wkWebView.load(request)
        } else {
            loginSettingWebView(id: id, pw: pw, token: token)
        }
        
    }
    
    func loginSettingWebView(id: String, pw: String, token: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + loginSuccessURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'id';" +
            "input.value = '\(id)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'pw';" +
            "input.value = '\(pw)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'token';" +
            "input.value = '\(token)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'device';" +
            "input.value = 'ios';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
//        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }
}

extension HomeController: LogoutDelegate, WithdrawalDelegate {
    func logout() {
        
        guard let url = URL(string: domain + logoutURL) else {
            print("로그아웃 url 잘못됨")
            return
        }
        
        guard let idx = UserDefaults.standard.object(forKey: "idx") as? String else {
            print("idx 없음")
            return
        }
        
        if #available(iOS 11.0, *) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let postString = "login=\(idx)"
            request.httpBody = postString.data(using: .utf8)
            wkWebView.load(request)
        } else {
            logoutSettingWebView(idx: idx)
        }
        
        removeCompanyInfo()
        changeRootVC()
    }
    
    func withdraw(id: String, pw: String) {
        print("회원탈퇴 함수 실행")
        var request = URLRequest(url: URL(string : domain + withdrawalURL)!)
        
        if #available(iOS 11.0, *) {
            request.httpMethod = "POST"
            let postString = "id=\(id)&pw=\(pw)"
            request.httpBody = postString.data(using: .utf8)
            print("회원탈퇴 url로드")
            wkWebView.load(request)
        } else {
            withdrawlSettingWebView(id: id, pw: pw)
        }
        
        removeCompanyInfo()
        changeRootVC()
    }
    
    func logoutSettingWebView(idx: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + logoutURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'login';" +
            "input.value = '\(idx)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }
    
    func withdrawlSettingWebView(id: String, pw: String) {
        
        let javascriptPOSTRedirect: String = "" +
            "var form = document.createElement('form');" +
            "form.method = 'POST';" +
            "form.action = '\(domain + withdrawalURL)';" +
            "" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'id';" +
            "input.value = '\(id)';" +
            "form.appendChild(input);" +
            "var input = document.createElement('input');" +
            "input.type = 'text';" +
            "input.name = 'pw';" +
            "input.value = '\(pw)';" +
            "form.appendChild(input);" +
            "" +
        "form.submit();"
        //        print(javascriptPOSTRedirect)
        
        wkWebView.evaluateJavaScript(javascriptPOSTRedirect, completionHandler: nil)
    }
    
    private func removeCompanyInfo() {
        
        wkWebView.evaluateJavaScript("setCompanyDelete()") { (result, error) in
            if let error = error {
                print("error : \(error)")
            } else {
                print("result : \(result)")
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "ID")
        UserDefaults.standard.removeObject(forKey: "PW")
        UserDefaults.standard.removeObject(forKey: "idx")
        UserDefaults.standard.removeObject(forKey: "getCompanyInfo")
        
    }
    
    private func changeRootVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewContoller = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        
        var option = UIWindow.TransitionOptions(direction: .toTop, style: .easeInOut)
        option.duration = 0.5
        UIApplication.shared.keyWindow?.setRootViewController(loginViewContoller, options: option)
        
        //        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
        //            UIView.transition(with: appdelegate.window!,
        //                              duration: 0.3,
        //                              options: .transitionCrossDissolve,
        //                              animations: {
        //                                appdelegate.window?.rootViewController = loginViewContoller
        //            },
        //                              completion: nil)
        //            appdelegate.window?.rootViewController = loginViewContoller
        //        }
    }
}

