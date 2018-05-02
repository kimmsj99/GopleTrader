//
//  FindIDController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 20..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class FindIDController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var underLine: UIView!
    
    @IBOutlet weak var findBtn: UIButton!
    @IBOutlet weak var certifiNumBtn: UIButton!
    
    @IBOutlet weak var buttonInterval: NSLayoutConstraint!
    
    var viewNavBar = UIView()
    
    let backBtn = UIButton()
    
    var phoneNumHiphone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        phoneNumTF.delegate = self
        
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y:0),
            size: CGSize(width: self.view.frame.size.width, height: 44)))
        
        viewNavBar.backgroundColor = UIColor.white
        
        backBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backBtn.frame = CGRect(x: 5, y: 12, width: 47, height: 35)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        lineView.backgroundColor = UIColor.init(hex: "d6d6d6")
        certifiNumBtn.addSubview(lineView)
        
        let attributes = [NSForegroundColorAttributeName : UIColor.init(hex: "C0C0C0"),
                               NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue] as! [String : Any]
        
        let attributeString = NSMutableAttributedString(string: "Forgot PW",
                                                        attributes: attributes)
        
        findBtn.setAttributedTitle(attributeString, for: .normal)
        
        phoneNumTF.becomeFirstResponder()
        phoneNumTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UserDefaults.standard.removeObject(forKey: "certifiNum")
        UserDefaults.standard.removeObject(forKey: "findPW")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        phoneNumTF.becomeFirstResponder()
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
        UIView.animate(withDuration: 3,
                       animations: {
                        self.buttonInterval.constant = keyboardSize.height
        })
        
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
        //        scrollView.setContentOffset(offset, animated: true)
        
    }
    
    func keyboardWillHide(noti: Notification) {
        
        UIView.animate(withDuration: 3,
                       animations: {
                        self.buttonInterval.constant = 0
        })
        
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text! != "" {
            underLine.backgroundColor = textColor
        } else {
            underLine.backgroundColor = UIColor.init(hex: "d5d5d5")
        }
    }
    
    @IBAction func goFindPW(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let findPasswordController = storyboard.instantiateViewController(withIdentifier: "FindPasswordController")
        self.present(findPasswordController, animated: true, completion: nil)
    }
    
    @IBAction func goCertifiNum(_ sender: UIButton) {
        
        if phoneNumTF.text?.isEmpty == true {
            
            basicAlert(target: self, title: nil, message: "전화번호를 입력해주십시오")
        } else {
            
            guard isValidPhoneNum(str: phoneNumTF.text!) else {
                return basicAlert(target: self, title: nil, message: "올바른 전화번호 형식이 아닙니다.")
            }
            
            let number = random(length: 4)
            print("인증번호 : \(number)")
            UserDefaults.standard.set(number, forKey: "certifiNum")
            
            let phoneNum = phoneNumTF.text!
            
            let index = phoneNum.index(phoneNum.startIndex, offsetBy: 3)
            
            var first = phoneNum.substring(to: index)
            first += "-"
            
            var start = phoneNum.index(phoneNum.startIndex, offsetBy: 3)
            var end = phoneNum.index(phoneNum.endIndex, offsetBy: -4)
            var length = start..<end
            
            var second = phoneNum.substring(with: length)
            second += "-"
            
            start = phoneNum.index(phoneNum.startIndex, offsetBy: 7)
            end = phoneNum.index(phoneNum.endIndex, offsetBy: 0)
            length = start..<end
            
            let last = phoneNum.substring(with: length)
            
            phoneNumHiphone = first + second + last
            
            UserDefaults.standard.set(phoneNumHiphone, forKey: "phone")
            
            let paramter = ["phone":phoneNumHiphone,
                            "num":number,
                            "find":"1"]
            print("paramter : \(paramter)")
            
            Alamofire.request(domain + findIDURL,
                              method: .post,
                              parameters: paramter,
                              encoding: URLEncoding.default,
                              headers: nil).response(completionHandler: {
                                (response) in
                                self.parseNumber(response.data!)
                              })
            
        }
        
    }
    
    func doneBtn(_ sender: UIButton) {
        if (UserDefaults.standard.object(forKey: "certifiNum") != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func touch() {
        self.view.endEditing(true)
    }
    
    func parseNumber(_ data: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            print(readableJSON)
            
            if readableJSON["return"] as? NSNumber == 1 {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let certifiNumberController = storyboard.instantiateViewController(withIdentifier: "CertifiNumberController")
                self.navigationController?.pushViewController(certifiNumberController, animated: true)
                
            } else {
                basicAlert(target: self, title: "인증번호 보내기 실패", message: "전화번호를 다시 확인해주세요")
            }
        } catch {
            basicAlert(target: self, title: nil, message: "파싱 실패")
        }
    }

}
