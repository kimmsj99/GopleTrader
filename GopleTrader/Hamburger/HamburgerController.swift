//
//  HamburgerController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 20..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class HamburgerController: UIViewController {
    
    static var type = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
        
        if HamburgerController.type == "홈" {
            //            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: false, completion: {
                HamburgerController.type = ""
            })
        }
//        else if HamburgerController.type == "등록" {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let registController = storyboard.instantiateViewController(withIdentifier: "RegistController")
//            self.present(registController, animated: true, completion: nil)
//        } else if HamburgerController.type == "스케줄" {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let scheduleController = storyboard.instantiateViewController(withIdentifier: "ScheduleController")
//            self.present(scheduleController, animated: true, completion: nil)
//        } else if HamburgerController.type == "설정" {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let settingTableController = storyboard.instantiateViewController(withIdentifier: "SettingTableController")
//            self.present(settingTableController, animated: true, completion: nil)
//        }
 
    }

    @IBAction func goHome(_ sender: UIButton) {
        if ((self.presentingViewController as? HomeController) != nil) {
            self.dismiss(animated: true, completion: nil)
        } else {
            HamburgerController.type = "홈"
            self.dismiss(animated: true, completion: nil)
        }
//        self.dismiss(animated: true, completion: nil)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let homeController = storyboard.instantiateViewController(withIdentifier: "HomeController")
//        self.present(homeController, animated: true, completion: nil)
    }
    
    @IBAction func goRegister(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registController = storyboard.instantiateViewController(withIdentifier: "RegistController")
        self.present(registController, animated: true, completion: nil)
        
//        if ((self.presentingViewController as? HomeController) != nil) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let registController = storyboard.instantiateViewController(withIdentifier: "RegistController")
//            self.present(registController, animated: true, completion: nil)
//        } else {
//            HamburgerController.type = "등록"
//            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func goSchedule(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scheduleController = storyboard.instantiateViewController(withIdentifier: "ScheduleController")
        self.present(scheduleController, animated: true, completion: nil)
        
//        if ((self.presentingViewController as? HomeController) != nil) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let scheduleController = storyboard.instantiateViewController(withIdentifier: "ScheduleController")
//            self.present(scheduleController, animated: true, completion: nil)
//        } else {
//            HamburgerController.type = "스케줄"
//            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func goSetting(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingTableController = storyboard.instantiateViewController(withIdentifier: "SettingTableController")
        self.present(settingTableController, animated: true, completion: nil)
        
//        if ((self.presentingViewController as? HomeController) != nil) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let settingTableController = storyboard.instantiateViewController(withIdentifier: "SettingTableController")
//            self.present(settingTableController, animated: true, completion: nil)
//        } else {
//            HamburgerControll정r.type = "설정"
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    @IBAction func doneHamburger(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
