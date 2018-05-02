//
//  Method.swift
//  Gople
//
//  Created by 김민주 on 2017. 11. 9..
//  Copyright © 2017년 김민주. All rights reserved.
//

import Foundation
import UIKit

//기본 Alert
public func basicAlert(target: UIViewController, title: String?, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(okAction)
    target.present(alert, animated: true, completion: nil)
}

//키보드에 닫기 버튼 추가
public func addToolBar(target: UIView, textField: UITextField) {
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: target, action: #selector(UIView.endEditing(_:)))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    textField.inputAccessoryView = keyboardToolbar
}

//인증번호 만들기
public func random(length: Int = 6) -> String {
    let base = "0123456789"
    var randomString: String = ""
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.characters.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    }
    return randomString
}

//핸드폰 정규식
public func isValidPhoneNum(str: String) -> Bool{
    let phoneNumRegEx = "^\\d{3}\\d{4}\\d{4}$"
    
    let phoneNumTest = NSPredicate(format: "SELF MATCHES %@", phoneNumRegEx)
    return phoneNumTest.evaluate(with: str)
}

//패스워드 정규식
public func isValidPassword(str: String) -> Bool{
//    let passwordRegEx = "&(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6}$"
    let passwordRegEx = "^[a-zA-Z0-9]*$"
    
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: str)
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            
            let idx = readableJSON["idx"] as! String
            let alert = readableJSON["alert"] as! String
            UserDefaults.standard.set(idx, forKey: "idx")
            UserDefaults.standard.set(alert, forKey: "alert")
            
            return readableJSON
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

public func changeView(storyboardName: String, target: UIViewController) {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let registController = storyboard.instantiateViewController(withIdentifier: storyboardName)
    target.present(registController, animated: true, completion: nil)
    
}
