//
//  ChangePasswordController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 21..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var underLine: UIView!
    
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var buttonInterval: NSLayoutConstraint!
    
    let phone = UserDefaults.standard.object(forKey: "phone") as! String
    
    var password = String()
    var realPass = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passTF.delegate = self
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        lineView.backgroundColor = UIColor.init(hex: "d6d6d6")
        completeBtn.addSubview(lineView)
        
        completeBtn.addTarget(self, action: #selector(completeAction(_:)), for: .touchUpInside)

        passTF.becomeFirstResponder()
        passTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        passTF.becomeFirstResponder()
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
        UIView.animate(withDuration: 3,
                       animations: {
                        self.buttonInterval.constant = 130
        })
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
        //        scrollView.setContentOffset(offset, animated: true)
        
    }
    
    func keyboardWillHide(noti: Notification) {
        
        UIView.animate(withDuration: 3,
                       animations: {
                        self.buttonInterval.constant = 334
        })
        
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        print(textField.text!)
        
        if textField.text! != "" {
            underLine.backgroundColor = textColor
        } else {
            underLine.backgroundColor = UIColor.init(hex: "d5d5d5")
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return true
        }
        
        realPass += string
        
        var hashPassword = String()
        let newChar = string.characters.first
        let offsetToUpdate = password.index(password.startIndex, offsetBy: range.location)
        
        if string.count == 0 {
            if password.endIndex.encodedOffset == 0 {
                passTF.text = ""
                underLine.backgroundColor = UIColor.init(hex: "d5d5d5")
                realPass.removeAll()
                password.removeAll()
                return true
            } else {
                realPass.remove(at: offsetToUpdate)
                password.remove(at: offsetToUpdate)
                return true
            }
        } else {
            underLine.backgroundColor = textColor
            password.insert(newChar!, at: offsetToUpdate)
        }
        
        for _ in password.characters {
            hashPassword += "*"
        }
        textField.text = hashPassword
        
        return false
       
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.requestNewPW()
        
        return true
    }
    
    func completeAction(_ sender: UIButton){
        self.requestNewPW()
    }
    
    func requestNewPW() {
        let parameter = ["phone":phone,
                        "pw":realPass]
        print(parameter)
        
        Alamofire.request(domain + changePWURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            self.parseNewPW(response.data!)
        }
    }
    
    func parseNewPW(_ data: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            print(readableJSON)
            
            if readableJSON["return"] as? NSNumber == 1 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController")
                self.present(loginController, animated: true, completion: nil)
            } else {
                basicAlert(target: self, title: "비밀번호 변경 실패", message: "비밀번호를 다시 설정해주세요.")
            }
        } catch {
            basicAlert(target: self, title: nil, message: "파싱 실패")
            
        }
    }
    
}
