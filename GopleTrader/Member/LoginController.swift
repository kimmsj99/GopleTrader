//
//  ViewController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 10..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginCenter: NSLayoutConstraint!
    
    @IBOutlet weak var idPlace: UILabel!
    @IBOutlet weak var pwPlace: UILabel!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    @IBOutlet weak var findBtn: UIButton!
    
    weak var loginDelegate : LoginDelegate?
    
    let myData = UserDefaults.standard
    
    var password = String()
    var realPass = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginCenter.constant = ( self.view.frame.height - joinBtn.frame.height ) / 2
        pwTextField.delegate = self
        
        addToolBar(target: self.view, textField: idTextField)
        addToolBar(target: self.view, textField: pwTextField)
        
        idTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        lineView.backgroundColor = UIColor.init(hex: "1dd6ed")
        joinBtn.addSubview(lineView)
        
        loginBtn.clipsToBounds = true
        loginBtn.layer.cornerRadius = 5
        
        var attributes: [String : Any]!
        
        if let font = UIFont(name: "DaeHan-Bold", size: 13) {
            attributes = [NSFontAttributeName : font,
            NSForegroundColorAttributeName : UIColor.init(hex: "ABABAB"),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
        }
        
        let attributeString = NSMutableAttributedString(string: "Forgot ID/PW",
                                                        attributes: attributes)
        findBtn.setAttributedTitle(attributeString, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        scrollView.keyboardDismissMode = .interactive
    }
    
    func keyboardWillShow(noti: Notification) {
        
//        guard let userInfo = noti.userInfo else { return }
//        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//
//        var contentInset:UIEdgeInsets = scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        scrollView.contentInset = contentInset
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 44, right: 0)

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
//        scrollView.setContentOffset(offset, animated: true)
        
    }
    
    func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == idTextField.self {
            idPlace.isHidden = true
            if textField.text == "" {
                idPlace.isHidden = false
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 2{
            pwPlace.isHidden = true
            
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
                    pwTextField.text = ""
                    pwPlace.isHidden = false
                    realPass.removeAll()
                    password.removeAll()
                    return true
                } else {
                    realPass.remove(at: offsetToUpdate)
                    password.remove(at: offsetToUpdate)
                    return true
                }
            } else {
                password.insert(newChar!, at: offsetToUpdate)
            }

            for _ in password.characters {
                
                hashPassword += "*"
            }
            textField.text = hashPassword
            
            return false
        }
        return true
    }

    @IBAction func findAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let findIDController = storyboard.instantiateViewController(withIdentifier: "FindIDController")
        self.present(findIDController, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if let token = UserDefaults.standard.object(forKey: "token") {
            if idTextField.text?.isEmpty == true {
                basicAlert(target: self, title: nil, message: "아이디를 입력해주세요.")
            } else {
                if pwTextField.text?.isEmpty == true {
                    basicAlert(target: self, title: nil, message: "비밀번호를 입력해주세요.")
                } else {
                    let parameter = ["id":idTextField.text!,
                                     "pw":realPass,
                                     "token":token,
                                     "device":"ios"]
                    
                    print(parameter)
                    
                    Alamofire.request(domain + loginURL,
                                      method: .post,
                                      parameters: parameter,
                                      encoding: URLEncoding.default,
                                      headers: nil).response(completionHandler: {
                                        (response) in
                                        do {
                                            let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                            print(readableJSON)
                                            
                                            if readableJSON["return"] as? NSNumber == 1 {
                                                
                                                let id = self.idTextField.text!
                                                let pw = self.realPass
                                                
                                                if let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as? HomeController {
                                                    
                                                    self.loginDelegate = homeController
                                                    UserDefaults.standard.set(id, forKey: "ID")
                                                    UserDefaults.standard.set(pw, forKey: "PW")
                                                    self.present(homeController, animated: true, completion: {
                                                        self.loginDelegate?.login(id: id, pw: pw)
                                                    })
                                                }
                                                
                                                
                                            } else {
                                                basicAlert(target: self, title: "로그인 실패", message: "아이디나 비밀번호를 다시 입력해주세요.")
                                            }
                                        } catch {
                                            basicAlert(target: self, title: nil, message: "파싱 실패")
                                        }
                                      })
                }
            }
        }
    }
    
}

