//
//  JoinController.swift
//  GopleComp
//
//  Created by 김민주 on 2017. 11. 10..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class JoinController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var backInterval: NSLayoutConstraint!
    @IBOutlet weak var titleInterval: NSLayoutConstraint!
    
    @IBOutlet weak var joinTitle: UILabel!
    
    @IBOutlet weak var phoneNumBtn: UIButton!
    @IBOutlet weak var certifiNumBtn: UIButton!
    @IBOutlet weak var checkIDBtn: UIButton!
    @IBOutlet weak var uploadImgBtn: UIButton!
    
    @IBOutlet weak var overTime: UILabel!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var certifiNumTF: UITextField!
    @IBOutlet weak var checkIDTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var passCheckTF: UITextField!
    
    @IBOutlet weak var imgTableView: UITableView!
    
    @IBOutlet weak var serviceBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var allAgreeBtn: UIButton!
    
    @IBOutlet weak var joinBtn: UIButton!
    
    let myData = UserDefaults.standard
    
    var checkID = false
    
    var wkWebView = WKWebView()
    
    var picker: UIImagePickerController = UIImagePickerController()
    var pickImage: UIImage?
    
    var timer: Timer!
    var certificationNum = ""
    var seconds = 180
    
    var phoneNumHiphone: String!
    
    var password = String()
    var passwordCheck = String()
    var realPass = ""
    var realPassCheck = ""
    var companyImgLink = ""
    
    let company = CompanyImg()
    
    weak var loginDelegate : LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        phoneTF.delegate = self
        passTF.delegate = self
        passCheckTF.delegate = self
        
        scrollView.bounces = false
        
        overTime.isHidden = true
        tableHeight.constant = 0
        
        imgTableView.tableFooterView = UIView()
        
        addToolBar(target: self.view, textField: companyTF)
        addToolBar(target: self.view, textField: phoneTF)
        addToolBar(target: self.view, textField: certifiNumTF)
        addToolBar(target: self.view, textField: checkIDTF)
        addToolBar(target: self.view, textField: passTF)
        addToolBar(target: self.view, textField: passCheckTF)
        
        phoneTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        certifiNumTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        checkIDTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        scrollView.contentSize = contentView.frame.size
        
        guard #available(iOS 11.0, *) else {
            backInterval.constant += 20
            titleInterval.constant += 20
            return
        }
        
        // Do any additional setup after loading the view.
    }
    
    func keyboardWillShow(noti: Notification) {
        
        var userInfo = noti.userInfo
        let keyboardSize: CGSize = ((userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 44, right: 0)
        
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        var offset = scrollView.contentOffset
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height
//        scrollView.setContentOffset(offset, animated: true)
        
    }
    
    func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func certifiNumSend(_ sender: UIButton) {
        if phoneTF.text?.isEmpty == true {
            
            basicAlert(target: self, title: nil, message: "전화번호를 입력해주십시오")
        } else {
            
            guard isValidPhoneNum(str: phoneTF.text!) else {
                return basicAlert(target: self, title: nil, message: "올바른 전화번호 형식이 아닙니다.")
            }
            
            certificationNum = random(length: 6)
            print("인증번호 : \(certificationNum)")
            
            let phoneNum = phoneTF.text!
            
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
            
            print(phoneNumHiphone!)
            
            let paramter = ["phone":phoneNumHiphone!,
                            "num":certificationNum]
            print("paramter : \(paramter)")
            
            Alamofire.request(domain + certifiNumURL,
                              method: .post,
                              parameters: paramter,
                              encoding: URLEncoding.default,
                              headers: nil).response(completionHandler: {
                                (response) in
                                self.parsePhoneNum(data: response.data!)
                              })
            
        }
    }
    
    @IBAction func certifiNumCheck(_ sender: UIButton) {
        if certifiNumTF.text?.isEmpty == true {
            
            basicAlert(target: self, title: nil, message: "인증번호를 입력해주세요.")
        } else {
            
            if certificationNum == "" {
                basicAlert(target: self, title: nil, message: "인증번호를 발급받아주세요.")
            } else {
            
                guard certifiNumTF.text == certificationNum else {
                    return basicAlert(target: self, title: nil, message: "인증번호가 일치하지 않습니다.")
                    
                }
                
                basicAlert(target: self, title: nil, message: "전화번호가 인증되었습니다.")
                
                phoneTF.textColor = enableTextColor
                certifiNumTF.textColor = enableTextColor
                
                self.phoneNumBtn.setImage(#imageLiteral(resourceName: "number_n"), for: .normal)
                sender.setImage(#imageLiteral(resourceName: "ok_n"), for: .normal)
                
                phoneTF.isEnabled = false
                phoneNumBtn.isEnabled = false
                certifiNumTF.isEnabled = false
                sender.isEnabled = false
                overTime.isHidden = true
                stopTimer()
            }
        }
    }
    
    @IBAction func overlapIDCheck(_ sender: UIButton) {
        if checkIDTF.text?.isEmpty == true {
            basicAlert(target: self, title: nil, message: "아이디를 입력해주세요.")
        } else {
            if (checkIDTF.text?.characters.count)! < 5 && isValidPassword(str: checkIDTF.text!){
                basicAlert(target: self, title: nil, message: "아이디는 5~20자의 영문 소문자, 숫자만 사용가능합니다.")
            } else {
                print("아이디 : \(checkIDTF.text!)")
                let parameter = ["id":checkIDTF.text!]
                Alamofire.request(domain + checkValiIDURL,
                                  method: .post,
                                  parameters: parameter,
                                  encoding: URLEncoding.default,
                                  headers: nil).response(completionHandler: {
                                    (response) in
                                    self.parseID(data: response.data!)
                                  })
            }
        }
    }
    
    @IBAction func uploadImgAction(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "이미지 등록", preferredStyle: .actionSheet)
        
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
    
    @IBAction func serviceAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            
            if self.serviceBtn.isSelected == true && privacyBtn.isSelected == true {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            }
            
        } else {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            
            if self.serviceBtn.isSelected == false || privacyBtn.isSelected == false {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            }
        }
    }
    
    @IBAction func showSerivce(_ sender: UIButton) {
        changeText(str: "service")
    }
    
    @IBAction func privacyAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.privacyBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            
            if self.serviceBtn.isSelected == true && privacyBtn.isSelected == true {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            }
        } else {
            self.privacyBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            
            if self.serviceBtn.isSelected == false || privacyBtn.isSelected == false {
                self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            }
        }
    }
    
    @IBAction func showPrivacy(_ sender: UIButton) {
        changeText(str: "privacy")
    }
    
    @IBAction func allAgreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            self.privacyBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consetn_p"), for: .normal)
            
            self.serviceBtn.isSelected = true
            self.privacyBtn.isSelected = true
            
            print("모두 : \(sender.isSelected)")
            print("서비스 버튼 : \(serviceBtn.isSelected)")
            print("개인정보 버튼 : \(privacyBtn.isSelected)")
            
        } else {
            self.serviceBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            self.privacyBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            self.allAgreeBtn.setImage(#imageLiteral(resourceName: "consent_n"), for: .normal)
            
            self.serviceBtn.isSelected = false
            self.privacyBtn.isSelected = false
            
            print("모두 : \(sender.isSelected)")
            print("서비스 버튼 : \(serviceBtn.isSelected)")
            print("개인정보 버튼 : \(privacyBtn.isSelected)")
        }
    }
    
    func changeText(str: String) {
        UserDefaults.standard.removeObject(forKey: "push_url")
        UserDefaults.standard.set(str, forKey: "text")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let ntextController = storyboard.instantiateViewController(withIdentifier: "NTextController") as? NavigationController {
            self.present(ntextController, animated: true, completion: nil)
        }
    }
    
    @IBAction func joinAction(_ sender: UIButton) {
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            if companyTF.text?.isEmpty == true {
                basicAlert(target: self, title: nil, message: "업체명을 입력해주세요.")
            } else {
                if phoneTF.text?.isEmpty == true {
                    basicAlert(target: self, title: nil, message: "전화번호를 입력해주세요.")
                } else {
                    if certifiNumTF.text?.isEmpty == true {
                        basicAlert(target: self, title: nil, message: "인증번호를 입력해주세요.")
                    } else {
                        if checkIDTF.text?.isEmpty == true {
                            basicAlert(target: self, title: nil, message: "아이디를 입력해주세요.")
                        } else {
                            if passTF.text?.isEmpty == true || passCheckTF.text?.isEmpty == true {
                                basicAlert(target: self, title: nil, message: "비밀번호를 입력해주세요.")
                            } else {
                                print(realPass)
                                print(realPassCheck)
                                if realPass != realPassCheck {
                                    basicAlert(target: self, title: nil, message: "비밀번호를 확인해주세요.")
                                } else {
                                    if companyImgLink == "" {
                                        basicAlert(target: self, title: nil, message: "사업자등록증을 첨부해주세요.")
                                    } else {
                                        if serviceBtn.isSelected == false || privacyBtn.isSelected == false {
                                            basicAlert(target: self, title: nil, message: "이용약관에 모두 동의해야 회원가입이 가능합니다.")
                                        } else {
                                            let token = UserDefaults.standard.object(forKey: "token") as! String
                                            let paramter = ["id":checkIDTF.text!,
                                                            "pw":realPass,
                                                            "phone":phoneNumHiphone!,
                                                            "store":companyTF.text!,
                                                            "img":self.companyImgLink,
                                                            "token":token,
                                                            "device":"ios"]
                                            print(paramter)
                                        
                                            Alamofire.request(domain + joinURL,
                                                              method: .post,
                                                              parameters: paramter,
                                                              encoding: URLEncoding.default,
                                                              headers: nil)
                                            
                                            if let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as? HomeController {
                                                
                                                self.loginDelegate = homeController
                                                self.present(homeController, animated: true, completion: {
                                                    self.loginDelegate?.login(id : self.checkIDTF.text!, pw : self.realPass)
                                                })
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func parsePhoneNum(data: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            
            print("check Certification Number : \(readableJSON)")
            
            if readableJSON["return"] as? NSNumber == 1 {
                basicAlert(target: self, title: nil, message: "인증번호가 전송되었습니다.")
                phoneNumBtn.titleLabel?.lineBreakMode = .byCharWrapping
                var buttonText: NSString = "인증번호\n재전송"
                
                var substring1 = ""
                var substring2 = ""
                
                let newlineRange: NSRange = buttonText.range(of: "\n")
                
                if(newlineRange.location != NSNotFound) {
                    substring1 = buttonText.substring(to: newlineRange.location)
                    substring2 = buttonText.substring(from: newlineRange.location)
                }
                
                let font = UIFont.systemFont(ofSize: 12)
                let textFont: [String:AnyObject] = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: font]
                
                let attrString = NSMutableAttributedString(string: substring1, attributes: textFont)
                let attrString2 = NSMutableAttributedString(string: substring2, attributes: textFont)
                
                attrString.append(attrString2)
                
                phoneNumBtn.setAttributedTitle(attrString, for: .normal)
                
                self.runTimer()
                
            } else if readableJSON["return"] as? NSNumber == 2 {
                basicAlert(target: self, title: nil, message: "중복된 전화번호입니다.")
                phoneTF.text = ""
            } else {
                basicAlert(target: self, title: nil, message: "전화번호를 가져오지 못했습니다.")
            }
        } catch {
            basicAlert(target: self, title: nil, message: "파싱 실패")
        }
    }
    
    func parseID(data: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            
            print("check ID : \(readableJSON)")
            
            if readableJSON["return"] as? NSNumber == 1 {
                
                let alert = UIAlertController(title: "사용가능한 아이디입니다.", message: "이 아이디를 사용하시겠습니까?", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "확인", style: .default){
                    (_) in
                    
                    self.checkID = true
                    
                    self.checkIDTF.textColor = enableTextColor
                    self.checkIDBtn.setImage(#imageLiteral(resourceName: "check_n"), for: .normal)
                    
                    self.checkIDTF.isEnabled = false
                    self.checkIDBtn.isEnabled = false
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: false, completion: nil)
                
            } else {
                basicAlert(target: self, title: nil, message: "중복된 아이디입니다.")
                checkIDTF.text = ""
            }
        } catch {
            basicAlert(target: self, title: nil, message: "파싱 실패")
        }
    }
}


