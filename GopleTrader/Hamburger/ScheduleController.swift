//
//  ScheduleController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 20..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit

class ScheduleController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    var tmpView = UIView()
    
    var idx = ""
    
    let backBtn = UIButton()
    let subHamburgerBtn = UIButton()
    let sTitle = UILabel()
    
    let datePicker = UIDatePicker()
    let pickerParentView = UIView()
    
    var yearDate: Int = 0
    var monthDate: Int = 0
    
    static var funcName = ""
    
    var webViewBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = WKUserContentController()
        controller.add(self, name: "setMenuData")
        controller.add(self, name: "onLoadDateSet")
        controller.add(self, name: "onLoadDate")
        controller.add(self, name: "goSchedule")
        controller.add(self, name: "onCall")
        controller.add(self, name: "onWebView")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller

        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        wkWebView.scrollView.bounces = true
        wkWebView.scrollView.isScrollEnabled = false
        
        if ((UserDefaults.standard.object(forKey: "idx") as? String) != nil) {
            idx = UserDefaults.standard.object(forKey: "idx") as! String
        }
        
        var url = ""
        
        if UserDefaults.standard.object(forKey: "push_url") != nil {
            
            let push_url = UserDefaults.standard.object(forKey: "push_url") as! String
            url = domain + push_url
            
            sTitle.textColor = UIColor.white
            sTitle.center.x = self.view.frame.width / 2
            backBtn.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
            UIApplication.shared.statusBarStyle = .lightContent
            
        } else {
            url = domain + scheduleURL + "/\(idx)"
        }
        
        let request = URLRequest(url: URL(string : url)!)
        wkWebView.load(request)
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            wkWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant : 15).isActive = true
        } else {
            wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 15).isActive = true
        }
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webViewBottom = wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        webViewBottom.isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
        
        if ScheduleController.funcName != "" {
            self.wkWebView.evaluateJavaScript("\(ScheduleController.funcName)()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                    ScheduleController.funcName = ""
                }
            })
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        let webViewBottomConstant = keyboardSize.height
        
        UIView.animate(withDuration: 0.5) {
            self.webViewBottom.constant = -webViewBottomConstant
            self.view.layoutIfNeeded()
        }
        
        print("keyboard show = \(webViewBottom.constant)")
        
    }
    
    func keyboardWillHide(noti: Notification) {
        
        UIView.animate(withDuration: 0.5) {
            self.webViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }

}

extension ScheduleController {
    func createNavigation(title: String, backColor: UIColor, textColor: UIColor, backImage: UIImage, hamburgerImage: UIImage) {
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
        
        sTitle.text = title
        sTitle.font = UIFont(name: "DaeHan-Bold", size: 20)
        sTitle.textColor = textColor
        sTitle.sizeToFit()
        sTitle.textAlignment = .center
        sTitle.center = CGPoint(x: self.view.frame.width / 2, y: viewNavBar.frame.height / 2)
        viewNavBar.addSubview(sTitle)
        
        subHamburgerBtn.setImage(hamburgerImage, for: .normal)
        subHamburgerBtn.frame = CGRect(x: self.view.frame.width - 50, y: 14, width: 37, height: 33)
        subHamburgerBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(subHamburgerBtn)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func doneBtn(_ sender: UIButton) {
        if UserDefaults.standard.object(forKey: "push_url") != nil {
            UserDefaults.standard.removeObject(forKey: "push_url")
            self.dismiss(animated: true, completion: nil)
        } else {
            wkWebView.evaluateJavaScript("back()", completionHandler: { result, error in
                if let error = error {
                    print(error)
                } else {
                    if ScheduleController.funcName != "" {
                        self.wkWebView.evaluateJavaScript("\(ScheduleController.funcName)()", completionHandler: { (result, error) in
                            if let error = error {
                                print(error)
                            } else {
                                print(result)
                                ScheduleController.funcName = ""
                            }
                        })
                    }
                    
                    if self.wkWebView.url == URL(string: domain + scheduleURL + "/\(self.idx)") || self.wkWebView.url == URL(string : domain + calenderURL + "/\(self.idx)"){
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            
                            self.pickerParentView.frame.origin.y = self.view.frame.height
                            self.pickerParentView.removeFromSuperview()
                            
                        }, completion: { (success) in
                            if success {
                                print("애니메이션 완료")
                            }
                        })
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
        }
    }
}

extension ScheduleController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "setMenuData" {
            print("\(message.name) : \(message.body)")
            if let scriptMessage = message.body as? [AnyObject]  {
                
                var title: String!
                var titleColor: UIColor!
                var color: UIColor!
                var back = UIImage()
                var hamburger = UIImage()
                
                if let scriptTitle = scriptMessage[0] as? String {
                    title = scriptTitle
                }
                if let scriptColor = scriptMessage[1] as? Int {
                    //Color => 색상 1: 흰색, 2: 하늘색
                    if scriptColor == 1 {
                        color = UIColor.white
                        titleColor = UIColor.black
                        UIApplication.shared.statusBarStyle = .default
                        back = #imageLiteral(resourceName: "back")
                    } else if scriptColor == 2 {
                        color = mainColor
                        titleColor = UIColor.white
                        back = #imageLiteral(resourceName: "back_white")
                        UIApplication.shared.statusBarStyle = .lightContent
                    }
                    
                }
                if let menu = scriptMessage[2] as? Int {
                    //Menu => 노출유무 1: 노출, 0: 비노출
                    if menu == 1 {
                        hamburger = #imageLiteral(resourceName: "sub_hamburger")
                    } else if menu == 0 {
                        hamburger = UIImage()
                    }
                    
                }
                
                createNavigation(title: title, backColor: color, textColor: titleColor, backImage: back, hamburgerImage: hamburger)
            }
        }
        
        if message.name == "onLoadDateSet" {
            print("\(message.name) : \(message.body)")
            
            let pickerParentOriginY = self.view.frame.height
            let pickerParentY = self.view.frame.height - 300 + 44
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 256)
            datePicker.backgroundColor = UIColor.white
            datePicker.datePickerMode = .date
            
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
            toolbar.setItems([flexBarButton, doneButton], animated: false)
            
            pickerParentView.frame = CGRect(x: 0, y: pickerParentOriginY, width: self.view.frame.width, height: 300)
            pickerParentView.addSubview(datePicker)
            pickerParentView.addSubview(toolbar)
            
            wkWebView.addSubview(pickerParentView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.pickerParentView.frame.origin.y = pickerParentY
                
            }, completion: { (success) in
                if success {
                    print("애니메이션 완료")
                }
            })
        }
        
        if message.name == "onLoadDate" {
            print("\(message.name) : \(message.body)")
            
            let date = message.body as! String
            let index = date.index(date.startIndex, offsetBy: 4)
            
            let year = date.substring(to: index)
            
            let start = date.index(date.startIndex, offsetBy: 5)
            let end = date.index(date.endIndex, offsetBy: 0)
            let length = start..<end
            
            let month = date.substring(with: length)
            
            print(year)
            print(month)
            
            self.yearDate = Int(year)!
            self.monthDate = Int(month)!
            
            let monthYearPicker = MonthYearPickerView()
            monthYearPicker.onDateSelected = { (month: Int, year: Int) in
                let string = String(format: "%02d/%d", month, year)
                print(string)
                print("year: \(year)")
                print("month: \(month)")
                
                self.yearDate = year
                self.monthDate = month
            }
            
            let pickerParentOriginY = self.view.frame.height
            let pickerParentY = self.view.frame.height - 300 + 44
            
            monthYearPicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 256)
            monthYearPicker.backgroundColor = UIColor.white
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(monthDonePressed(_:)))
            toolbar.setItems([flexBarButton, doneButton], animated: false)
            
            pickerParentView.frame = CGRect(x: 0, y: pickerParentOriginY, width: self.view.frame.width, height: 300)
            pickerParentView.addSubview(monthYearPicker)
            pickerParentView.addSubview(toolbar)
            
            wkWebView.addSubview(pickerParentView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.pickerParentView.frame.origin.y = pickerParentY
                
            }, completion: { (success) in
                if success {
                    print("애니메이션 완료")
                }
            })
            
            
        }
        
        if message.name == "goSchedule" {
            print("\(message.name) : \(message.body)")
            
            ScheduleController.funcName = message.body as! String
        }
        
        if message.name == "onCall" {
            print("\(message.name) : \(message.body)")
            
            if let phone = message.body as? String {
                if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
        
        if message.name == "onWebView" {
            print("\(message.name) : \(message.body)")
            
            let url = message.body as! String
            
            UserDefaults.standard.set(url, forKey: "scheduleDetailURL")
            
            if let scheduleDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleDetailController") as? NavigationController {
                self.present(scheduleDetailVC, animated: true, completion: nil)
            }
        }
    }
    
    func donePressed(_ sender : Any) {
        //format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.string(from: datePicker.date)
        
        wkWebView.evaluateJavaScript("gRun.setDateDoc('\(date)')") { (result, error) in
            if let error = error {
                print(error)
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.pickerParentView.frame.origin.y = self.view.frame.height
                    self.pickerParentView.removeFromSuperview()
                    
                }, completion: { (success) in
                    if success {
                        print("애니메이션 완료")
                    }
                })
            }
        }
    }
    
    func monthDonePressed(_ sender: Any) {
        
        wkWebView.evaluateJavaScript("gRun.setCalendarData('\(yearDate)', '\(monthDate)')", completionHandler: { (result, error) in
            if let error = error {
                print(error)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.pickerParentView.frame.origin.y = self.view.frame.height
                    self.pickerParentView.removeFromSuperview()
                    
                }, completion: { (success) in
                    if success {
                        print("애니메이션 완료")
                    }
                })
            }
        })
    }
}

extension ScheduleController: WKNavigationDelegate {
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

extension ScheduleController: WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if wkWebView.url == URL(string: domain + scheduleURL + "/\(idx)") || wkWebView.url == URL(string : domain + calenderURL + "/\(idx)") {
            wkWebView.evaluateJavaScript("tabMove()", completionHandler: { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    print(result)
                }
            })
        }
    }
}
