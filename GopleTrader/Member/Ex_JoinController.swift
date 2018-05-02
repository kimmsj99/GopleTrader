//
//  Ex_JoinController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 17..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire

class CompanyImg {
    var companyImg: String?
    var companyLink: String?
}

extension JoinController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = imgTableView.dequeueReusableCell(withIdentifier: "cell") as! ImageUploadCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageUploadCell
        print(cell.frame)
        cell.backgroundColor = UIColor.init(hex: "f2f2f2")
        
        imgTableView.separatorStyle = .none
        
        cell.company = self.company
        
        cell.imgDelete.addTarget(self, action: #selector(deleteCompanyImg), for: .touchUpInside)
        
        return cell
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 5 || textField.tag == 6 {
            
            if textField.tag == 5 {
                if string == "\n" {
                    self.passCheckTF.becomeFirstResponder()
                    return true
                }
                
                realPass += string
                
                var hashPassword = String()
                let newChar = string.characters.first
                let offsetToUpdate = password.index(password.startIndex, offsetBy: range.location)
                
                if string.count == 0 {
                    if password.endIndex.encodedOffset == 0 {
                        textField.text! = ""
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
                
            } else if textField.tag == 6 {
                
                if string == "\n"{
                    textField.resignFirstResponder()
                    return true
                }
                
                realPassCheck += string
                
                var hashPassword = String()
                let newChar = string.characters.first
                let offsetToUpdate = passwordCheck.index(passwordCheck.startIndex, offsetBy: range.location)
                
                if string.count == 0 {
                    if passwordCheck.endIndex.encodedOffset == 0 {
                        textField.text! = ""
                        realPassCheck.removeAll()
                        passwordCheck.removeAll()
                        return true
                    } else {
                        realPassCheck.remove(at: offsetToUpdate)
                        passwordCheck.remove(at: offsetToUpdate)
                        return true
                    }
                } else {
                    passwordCheck.insert(newChar!, at: offsetToUpdate)
                }
                
                for _ in passwordCheck.characters {
                    
                    hashPassword += "*"
                }
                textField.text = hashPassword
                
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField.tag == 2 {
            if textField.text! != "" {
                phoneNumBtn.setImage(#imageLiteral(resourceName: "number_p"), for: .normal)
            } else {
                phoneNumBtn.setImage(#imageLiteral(resourceName: "number_n"), for: .normal)
            }
        } else if textField.tag == 3 {
            if textField.text! != "" {
                certifiNumBtn.setImage(#imageLiteral(resourceName: "ok_p"), for: .normal)
            } else {
                certifiNumBtn.setImage(#imageLiteral(resourceName: "ok_n"), for: .normal)
            }
        } else if textField.tag == 4 {
            if textField.text! != "" {
                checkIDBtn.setImage(#imageLiteral(resourceName: "check_p"), for: .normal)
            } else {
                checkIDBtn.setImage(#imageLiteral(resourceName: "check_n"), for: .normal)
            }
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
        certificationNum = ""
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.picker = UIImagePickerController()
            self.picker.sourceType = .camera
            self.picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }else{
            self.openPhotoLibrary()
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.picker = UIImagePickerController()
            self.picker.sourceType = .photoLibrary
            self.picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let imageData = UIImagePNGRepresentation(image)!
        
        self.uploadImage(imageData)
        
        pickImage = UIImage(data: imageData)!
        
    }
    
    func uploadImage(_ data: Data) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName: "file[0]", fileName: "image.png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(),
           to: domain + companyImgURL,
           method: .post,
           headers: nil) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("response : \(response)")
                    
                    if let dic = response.result.value as? [String : AnyObject] {
                        
                        DispatchQueue.main.async {
                            let url = dic["return"] as? String
                            self.company.companyImg = url
                            self.company.companyLink = url
                            self.companyImgLink = url!
                            UIView.animate(withDuration: 0.3, animations: {
                                self.tableHeight.constant = 51
                                self.imgTableView.layoutIfNeeded()
                            }, completion: { (success) in
                                if success {
                                    self.imgTableView.reloadData()
                                }
                            })
                        }
                        
                    }
                    
                    if let err = response.error {
                        print(err)
                        return
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteCompanyImg(){
        DispatchQueue.main.async {
            self.company.companyImg = ""
            self.company.companyLink = ""
            self.companyImgLink = ""
            
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.tableHeight.constant = 0
                            self.imgTableView.layoutIfNeeded()
            }, completion: { (success) in
                            if success {
                                self.imgTableView.reloadData()
                            }
            })
        }
    }
}
