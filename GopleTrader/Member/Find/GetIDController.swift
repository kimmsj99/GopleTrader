//
//  GetIDController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 21..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class GetIDController: UIViewController {

    @IBOutlet weak var getID: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loginBtn.clipsToBounds = true
        loginBtn.layer.cornerRadius = 5
        
        let id = UserDefaults.standard.object(forKey: "findID") as! String
        
        let labelText: NSString = "이 번호로 가입된 고객님의 아이디는\(id) 입니다." as NSString
        
        let newlineRange: NSRange = labelText.range(of: id)
        
        var subString1 = ""
        var subString2 = ""
        
        if newlineRange.location != NSNotFound {
            
            subString1 = labelText.substring(to: newlineRange.location)
            
            let text = labelText.substring(from: newlineRange.location)
            
            let start = text.index(text.startIndex, offsetBy: id.characters.count)
            let end = text.index(text.endIndex, offsetBy: 0)
            let length = start..<end
            
            subString2 = text.substring(with: length)
            
        }
        let nsStrID: NSString = "\n" + id as NSString
        
        let font1 = UIFont(name: "Daehan-Bold", size: 17)
        let font2 = UIFont(name: "Daehan-Bold", size: 20)
        let textStyle1: [String : AnyObject] = [NSFontAttributeName: font1!,
                                                NSForegroundColorAttributeName : textColor2]
        let textStyle2: [String : AnyObject] = [NSFontAttributeName : font2!,
                                                NSForegroundColorAttributeName : mainColor]
        
        let attrString1 = NSMutableAttributedString(string: subString1, attributes: textStyle1)
        let attrID = NSMutableAttributedString(string: nsStrID as String, attributes: textStyle2)
        let attrString2 = NSMutableAttributedString(string: subString2, attributes: textStyle1)
        
        attrString1.append(attrID)
        attrString1.append(attrString2)
        
        getID.attributedText = attrString1
        getID.lineBreakMode = .byWordWrapping
        getID.numberOfLines = 0
    }

    @IBAction func loginAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController")
        self.present(loginController, animated: true, completion: nil)
    }
    
}
