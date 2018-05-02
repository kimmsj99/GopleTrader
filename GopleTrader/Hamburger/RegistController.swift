//
//  RegistController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import DKImagePickerController

class RegistController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate, UITextFieldDelegate {
    
    var wkWebView = WKWebView()
    var scrollView = UIScrollView()
    
    var viewNavBar: UIView!
    var tmpView = UIView()
    
    let backBtn = UIButton()
    let subHamburgerBtn = UIButton()
    let rTitle = UILabel()
    
    var idx = ""
    
    var picker = UIImagePickerController()
    let pickerController = DKImagePickerController()
    
    var imageData: Data?
    var imageDataArr = [Data]()
    var assets: [DKAsset]?
    
    var commentView = UIView()
    var commentBackImg = UIImageView()
    var commentTF = UITextField()
    var sendBtn = UIButton()
    var commentBottom: CGFloat! = 0
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            print(scrollView.adjustedContentInset)
        } else {
            // Fallback on earlier versions
        }
    }

    
//    var commentView : CommentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 59)))
        
        viewNavBar.backgroundColor = UIColor.white
        
        backBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backBtn.frame = CGRect(x: 5, y: 12, width: 47, height: 35)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
        
        let controller = WKUserContentController()
        controller.add(self, name: "setMenuData")
        controller.add(self, name: "setFileUpload")
        controller.add(self, name: "onLoadText")
        controller.add(self, name: "onLoadMenu")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
    
        wkWebView = WKWebView(frame: .zero, configuration: configuration)
        
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.isScrollEnabled = false
        
        scrollView.bounces = false
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false

        if ((UserDefaults.standard.object(forKey: "idx") as? String) != nil) {
            idx = UserDefaults.standard.object(forKey: "idx") as! String
        }
        
        let url = URL(string: domain + registURL + "/\(idx)")
        let request = URLRequest(url: url!)
        self.wkWebView.load(request)
        
//        let request = URLRequest(url: URL(string: "http://gople.ghsoft.kr/company/schedule/detail/sub/178")!)
//        self.wkWebView.load(request)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(wkWebView)
        
        
        if #available(iOS 11.0, *) {
//            scrollView.scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        } else {
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        }
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        wkWebView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        wkWebView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        wkWebView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
//        if #available(iOS 11.0, *) {
//            webViewBottomConstraint = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant : 0)
//        } else {
//            // Fallback on earlier versions
//        }
//        webViewBottomConstraint.isActive = true
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = wkWebView.scrollView.contentSize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if HamburgerController.type == "홈" {
//            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func touch() {
        self.view.endEditing(true)
    }
    
    var webViewBottomConstraint : NSLayoutConstraint!
    
//    @objc func keyboardWillShow(notification: Notification) {
//        var userInfo = notification.userInfo!
//
//        var keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? .zero
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//        containerScrollView.contentInset.bottom = keyboardFrame.size.height
//
//        picker.snp.updateConstraints { (maker) in
//            maker.height.equalTo(0)
//        }
//
//        toolBar.snp.updateConstraints { (maker) in
//            maker.bottom.equalTo(view).offset(keyboardFrame.size.height * -1)
//        }
//
//        UIView.animate(withDuration: 0.3,
//                       animations: {
//                        self.view.layoutIfNeeded()
//        }, completion: { (_) in
//            print("constraint 변경 완료")
//        })
//    }
//
//    @objc func keyboardWillHide(notification: Notification) {
//
//        containerScrollView.contentInset = .zero
//        toolBar.snp.updateConstraints { (maker) in
//            maker.bottom.equalTo(view).offset(0)
//        }
//
//        UIView.animate(withDuration: 0.3,
//                       animations: {
//                        self.view.layoutIfNeeded()
//        }, completion: { (_) in
//            print("constraint 변경 완료")
//        })
//
//    }
//
    
    
    func keyboardWillShow(noti: Notification) {

        var userInfo = noti.userInfo
//        var keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        var keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//        wkWebView.scrollView.contentInset.bottom = keyboardFrame.size.height
        
        var webViewBottomConstant: CGFloat!

        if wkWebView.url == URL(string: domain + reviewURL + "/\(idx)") {
            commentBottom =  keyboardFrame.size.height
            commentView.frame.origin.y = wkWebView.frame.height - (commentBottom + commentView.frame.height)
            
            scrollView.contentSize = CGSize(width: wkWebView.frame.width, height: wkWebView.scrollView.contentSize.height + keyboardFrame.size.height + commentView.frame.height)

        }
        
        scrollView.contentSize = CGSize(width: wkWebView.frame.width, height: wkWebView.scrollView.contentSize.height + keyboardFrame.size.height)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func keyboardWillHide(noti: Notification) {
        scrollView.contentSize = wkWebView.scrollView.contentSize
//        UIView.animate(withDuration: 1.3) {
//            self.webViewBottomConstraint.constant = 0
//            self.view.layoutIfNeeded()
//        }
        self.removeComment()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "setMenuData" {

            if let scriptMessage = message.body as? [AnyObject]  {
                if let title = scriptMessage[0] as? String {
                    if title.isEmpty {
                        
                        print("empty")
                    } else {
                        UserDefaults.standard.set("title", forKey: "setMenuData")
                        print("not emprty")
                    }
                }
                if let color = scriptMessage[1] as? Int {
                    //Color => 색상 1: 흰색, 2: 하늘색
                    if color == 1 {
                        viewNavBar.backgroundColor = UIColor.white
                    } else if color == 2 {
                        tmpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0 ))
                        tmpView.backgroundColor = mainColor
                        navigationController?.view.addSubview(tmpView)
                        
                        viewNavBar.backgroundColor = mainColor
                    }
                }
                if let menu = scriptMessage[2] as? Int {
                    //Menu => 노출유무 1: 노출, 0: 비노출
                    if menu == 1 {
                        viewNavBar.addSubview(subHamburgerBtn)
                    } else if menu == 0 {
                        subHamburgerBtn.removeFromSuperview()
                    }
                }
            }
        }
        if message.name == "setFileUpload" {
            print(message.body)
            
            if message.body as? NSNumber == 1 {
                let alert = UIAlertController(title: "이미지 등록", message: nil, preferredStyle: .actionSheet)
                
                let cameraAction = UIAlertAction(title: "사진 촬영하기", style: .default) { (action) in
                    self.openCamera()
                    
                }
                
                let galleryAction = UIAlertAction(title: "앨범에서 찾기", style: .default) { (action) in
                    self.openPhotoLibrary()
                    
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                picker.delegate = self
                
                alert.addAction(cameraAction)
                alert.addAction(galleryAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        if message.name == "onLoadText" {
            if let commentIdx = message.body as? Int {
                UserDefaults.standard.set(commentIdx, forKey: "commentIdx")
            }
            self.createComment()
        }
        
        if message.name == "onLoadMenu" {
            if let commentIdx = message.body as? Int {
                UserDefaults.standard.set(commentIdx, forKey: "commentIdx")
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let modifyAction = UIAlertAction(title: "수정", style: .default) { (action) in
                    UserDefaults.standard.set("수정", forKey: "commentUpdate")
                    self.createComment()
                }
                
                let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { (action) in
                    self.wkWebView.evaluateJavaScript("gRun.onLoadDelete('\(commentIdx)')", completionHandler: nil)
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                picker.delegate = self
                
                alert.addAction(modifyAction)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                
                  self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func doneBtn(_ sender: UIButton) {
        
        if wkWebView.url != URL(string: domain + registURL) && wkWebView.url != URL(string: domain + registURL + "/\(idx)") {
            wkWebView.evaluateJavaScript("back()", completionHandler: { result, error in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                    self.commentTF.resignFirstResponder()
                    self.commentView.removeFromSuperview()
                }
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showHamburger(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
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
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if self.wkWebView.url == URL(string : domain + registURL + "/\(self.idx)") {
            rTitle.removeFromSuperview()
            subHamburgerBtn.setImage(#imageLiteral(resourceName: "sub_hamburger"), for: .normal)
            subHamburgerBtn.frame = CGRect(x: self.view.frame.width - 50, y: 14, width: 37, height: 33)
            subHamburgerBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
//            subHamburgerBtn.addTarget(self, action: #selector(showHamburger(_:)), for: .touchUpInside)
            viewNavBar.addSubview(subHamburgerBtn)
            
        }
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.contentSize = wkWebView.scrollView.contentSize
//
//        if #available(iOS 11.0, *) {
////            wkWebView.scrollView.adjustedContentInsetDidChange()
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.scrollView.contentSize = wkWebView.scrollView.contentSize
        
        
        if wkWebView.url == URL(string: domain + modifyURL + "/\(idx)") {
            subHamburgerBtn.removeFromSuperview()
            rTitle.text = "상세화면 등록"
            rTitle.font = UIFont(name: "DaeHan-Bold", size: 20)
            rTitle.textColor = textColor
            rTitle.frame = CGRect(x: 0, y: 20, width: 117, height: 20)
            rTitle.frame.origin = CGPoint(x: 0, y: 20)
            rTitle.center.x = self.view.frame.width / 2
            viewNavBar.addSubview(rTitle)
            
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

