//
//  SettingTableController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 13..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class SettingTableController: UITableViewController {
    
    enum Mode {
        case logout
        case withdrawal
    }
    
    var wkWebView : WKWebView!
    var viewNavBar = UIView()
    let myData = UserDefaults.standard
    let backBtn = UIButton()
    let subHamburgerBtn = UIButton()
    weak var logoutDelegate : LogoutDelegate?
    weak var withdrawalDelegate : WithdrawalDelegate?
    
//    @IBOutlet weak var alertSwitch: UISwitch!
    @IBOutlet weak var push: UIButton!
                           
    let id = UserDefaults.standard.object(forKey: "ID") as! String
    let pw = UserDefaults.standard.object(forKey: "PW") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "alert") as? String == "1" {
            push.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
        } else {
            push.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
        }
        
        tableView.layer.borderColor = UIColor.init(hex: "c1c1c1").cgColor
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        createNavigationBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        switch row {
        case 0:
            print("서비스 이용약관")
            
            changeText(str: "service")
        case 1:
            print("개인정보 처리 방침")
            
            changeText(str: "privacy")
        case 2:
            print("알림설정")
        case 3:
            print("로그아웃")
            let alert = UIAlertController(title: nil, message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default, handler: { (_) in
                self.execDelegate(mode: .logout)
            })
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
                if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectionIndexPath, animated: true)
                }
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)

        case 4:
            print("탈퇴")
            let alert = UIAlertController(title: nil, message: "회원탈퇴 하시겠습니까?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default, handler: { (_) in
                self.execDelegate(mode: .withdrawal)
            })
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
                if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectionIndexPath, animated: true)
                }
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
        default:
            return
        }
    }
    
    private func changeText(str: String) {
        UserDefaults.standard.removeObject(forKey: "push_url")
        UserDefaults.standard.set(str, forKey: "text")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let textController = storyboard.instantiateViewController(withIdentifier: "TextController")
        self.navigationController?.pushViewController(textController, animated: true)
        viewNavBar.removeFromSuperview()
    }
    
    private func execDelegate(mode : Mode) {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let rootVC = appDelegate.window?.rootViewController
            //로그인VC -> HomeVC 일때
            if let loginVC = rootVC as? LoginController {
                if let homeVC = loginVC.presentedViewController as? HomeController {
                    switch mode {
                    case .logout:
                        
                        self.logoutDelegate = homeVC
                        self.logoutDelegate?.logout()
                        
                    case .withdrawal:
                        
                        self.withdrawalDelegate = homeVC
                        self.withdrawalDelegate?.withdraw(id: id, pw: pw)
                    }
                }
            } else {
                if let homeVC = rootVC as? HomeController {
                    switch mode {
                    case .logout:
                        
                        self.logoutDelegate = homeVC
                        self.logoutDelegate?.logout()
                        
                    case .withdrawal:
                        
                        self.withdrawalDelegate = homeVC
                        self.withdrawalDelegate?.withdraw(id: id, pw: pw)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    @IBAction func pushOnOff(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        myData.set(sender.isSelected, forKey: "push")

        var pushSetting = ""

        if sender.isSelected {
            sender.setImage(#imageLiteral(resourceName: "push_on"), for: .normal)
            pushSetting = "1"
        } else {
            sender.setImage(#imageLiteral(resourceName: "push_off"), for: .normal)
            pushSetting = "0"
        }

        var parameter = ["":""]
        var idx = ""

        if myData.object(forKey: "idx") != nil {
            idx = myData.object(forKey: "idx") as! String
            parameter = ["alert":pushSetting,
                         "idx":idx]
        }
        print(parameter)

        Alamofire.request(domain + alertUpdateURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response { (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]

                                print(readableJSON)

                                if readableJSON["return"] as? NSNumber == 1 {
                                    print("푸시 변경 성공")

                                    parameter = ["idx":idx]

                                    Alamofire.request(domain + newUserInfoURL,
                                                      method: .post,
                                                      parameters: parameter,
                                                      encoding: URLEncoding.default,
                                                      headers: nil).response(completionHandler: { (response) in
                                                        do {
                                                            let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                                            print(readableJSON)
                                                            
                                                            let alert = readableJSON["alert"] as! String
                                                            UserDefaults.standard.set(alert, forKey: "alert")
                                                            
                                                        } catch{
                                                            print(error)
                                                            print("파싱 실패")
                                                        }
                                                      })

                                } else {
                                    print("푸시 변경 실패")
                                }

                            } catch {
                                basicAlert(target: self, title: nil, message: "파싱 실패")
                            }
        }
    }
    
    
    
}

extension SettingTableController {
    func createNavigationBar() {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 59)))
        
        tableView.frame.origin = CGPoint(x: 0, y: 200)
        viewNavBar.backgroundColor = UIColor.white
        
        backBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backBtn.frame = CGRect(x: 5, y: 12, width: 47, height: 35)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        subHamburgerBtn.setImage(#imageLiteral(resourceName: "sub_hamburger"), for: .normal)
        subHamburgerBtn.frame = CGRect(x: self.view.frame.width - 50, y: 14, width: 37, height: 33)
        subHamburgerBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(subHamburgerBtn)
        
        let title = UILabel()
        title.text = "설정"
        title.font = UIFont(name: "DaeHan-Bold", size: 20)
        title.textColor = textColor
        title.frame = CGRect(x: 0, y: 20, width: 55, height: 20)
        title.center.x = self.view.frame.width / 2
        viewNavBar.addSubview(title)
        
        let underline = UIView(frame: CGRect(x: 0, y: viewNavBar.frame.height - 0.5, width: self.view.frame.width, height: 0.5))
        underline.backgroundColor = UIColor.init(hex: "c1c1c1")
        viewNavBar.addSubview(underline)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func doneBtn(_ sender: UIButton) {
//        if UserDefaults.standard.object(forKey: "text") != nil {
//
//            self.navigationController?.popViewController(animated: true)
//            UserDefaults.standard.removeObject(forKey: "text")
//        } else {
            self.dismiss(animated: true, completion: nil)
//        }
//        UserDefaults.standard.removeObject(forKey: "push_url")
        
    }
}
