//
//  CertifiNumberController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 20..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class CertifiNumberController: UIViewController {
    
    @IBOutlet weak var overTime: UILabel!
    @IBOutlet weak var certifiNumTF: UITextField!
    
    @IBOutlet weak var firstAst: UIImageView!
    @IBOutlet weak var secondAst: UIImageView!
    @IBOutlet weak var thirdAst: UIImageView!
    @IBOutlet weak var lastAst: UIImageView!
    
    let certifiNum = UserDefaults.standard.object(forKey: "certifiNum") as! String
    let phone = UserDefaults.standard.object(forKey: "phone") as! String
    
    var timer: Timer!
    var certificationNum = ""
    var seconds = 180
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        certifiNumTF.becomeFirstResponder()
        certifiNumTF.tintColor = .clear
        certifiNumTF.textColor = .clear
        certifiNumTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        firstAst.isHidden = true
        secondAst.isHidden = true
        thirdAst.isHidden = true
        lastAst.isHidden = true
        
        self.runTimer()

    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text?.characters.count == 0 {
            firstAst.isHidden = true
            secondAst.isHidden = true
            thirdAst.isHidden = true
            lastAst.isHidden = true
        } else if textField.text?.characters.count == 1 {
            firstAst.isHidden = false
            secondAst.isHidden = true
            thirdAst.isHidden = true
            lastAst.isHidden = true
        } else if textField.text?.characters.count == 2 {
            firstAst.isHidden = false
            secondAst.isHidden = false
            thirdAst.isHidden = true
            lastAst.isHidden = true
        } else if textField.text?.characters.count == 3 {
            firstAst.isHidden = false
            secondAst.isHidden = false
            thirdAst.isHidden = false
            lastAst.isHidden = true
        } else if textField.text?.characters.count == 4 {
            firstAst.isHidden = false
            secondAst.isHidden = false
            thirdAst.isHidden = false
            lastAst.isHidden = false
            
            if textField.text! == certifiNum {
                
                let stroyboard = UIStoryboard(name: "Main", bundle: nil)
                if UserDefaults.standard.object(forKey: "findPW") != nil {
                    let changePasswordController = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordController")
                    self.navigationController?.pushViewController(changePasswordController!, animated: true)
                } else {
                    let parameter = ["phone":phone]
                    print(parameter)
                    
                    Alamofire.request(domain + getFindIDURL,
                                      method: .post,
                                      parameters: parameter,
                                      encoding: URLEncoding.default,
                                      headers: nil).response(completionHandler: { (response) in
                                        self.requestID(response.data!)
                                      })
                }
                
            } else {
                basicAlert(target: self, title: nil, message: "인증번호를 다시 입력해주세요")
                
                firstAst.isHidden = true
                secondAst.isHidden = true
                thirdAst.isHidden = true
                lastAst.isHidden = true
                
                certifiNumTF.text = ""
            }
            
        } else {
            basicAlert(target: self, title: nil, message: "인증번호 초과")
        }
        
    }
    
    func runTimer() {
        seconds = 180
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        
        seconds -= 1
        
        let minutesLeft = Int(seconds) / 60 % 60
        let secondsLeft = Int(seconds) % 60
        overTime.text = "\(minutesLeft):\(secondsLeft)"
        overTime.isHidden = false
        
        if seconds == 0 {
            stopTimer()
            basicAlert(target: self, title: nil, message: "발송된 인증번호 시간이 만료되었습니다.")
        }
        
    }
    
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
        overTime.isHidden = true
    }
    
    func requestID(_ data: Data){
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
            print(readableJSON)
            
            if let id = readableJSON["id"] as? String {
                print(id)
                
                stopTimer()
                
                UserDefaults.standard.set(id, forKey: "findID")

                let stroyboard = UIStoryboard(name: "Main", bundle: nil)
                let getIDController = storyboard?.instantiateViewController(withIdentifier: "GetIDController")
                self.navigationController?.pushViewController(getIDController!, animated: true)

            } else {
                basicAlert(target: self, title: nil, message: "인증번호를 다시 입력해주세요")

                firstAst.isHidden = true
                secondAst.isHidden = true
                thirdAst.isHidden = true
                lastAst.isHidden = true

                certifiNumTF.text = ""
            }
        } catch {
            basicAlert(target: self, title: nil, message: "파싱 실패")
        }
    }
    
}
