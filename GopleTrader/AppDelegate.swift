//
//  AppDelegate.swift
//  GopleComp
//
//  Created by 김민주 on 2017. 11. 10..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let reachability = Reachability()!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
//        UINavigationBar.appearance().frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 59)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myData = UserDefaults.standard
        var rootController : UIViewController
        
        if myData.object(forKey: "ID") != nil && myData.object(forKey: "PW") != nil {
            rootController = storyboard.instantiateViewController(withIdentifier: "HomeController")
        } else {
            rootController = storyboard.instantiateViewController(withIdentifier: "LoginController")
        }
        
        self.window = UIWindow( frame: UIScreen.main.bounds )
        self.window?.rootViewController = rootController
        self.window?.makeKeyAndVisible()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().remoteMessageDelegate = self
        
        FirebaseApp.configure()
        
        // 요넘 덕분에 background, terminated 상태에서 노티를 받을 수 있다.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        setReachability()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // setAPNSToken:type:에 APN 토큰 및 토큰 유형을 제공합니다. type의 값을 올바르게 설정해야 함. 샌드박스 환경의 경우 FIRInstanceIDAPNSTokenTypeSandbox, 운영 환경의 경우 FIRInstanceIDAPNSTokenTypeProd로 설정. 유형을 잘못 설정하면 메시지가 앱에 전송되지 않음.
        
        Messaging.messaging().apnsToken = deviceToken as Data
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
        
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {

        if UserDefaults.standard.string(forKey: "token") == nil {
            if let refreshedToken = InstanceID.instanceID().token() {
                print("InstanceID token: \(refreshedToken)")

                UserDefaults.standard.set(refreshedToken, forKey: "token")
            }

        } else {
            print("token is exist")
        }

        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().disconnect()
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    func setReachability() {
        //인터넷 연결 체크
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                print("not reachable")
                
                let alertController = UIAlertController(title: "네트워크 환경을 확인해주세요.", message: "앱이 종료됩니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { (UIAlertAction) in
                    exit(0)
                })
                
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // on Foreground & onActive 앱이 구동 중일 때 푸쉬가 올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("\n[ FCM ] userInfo : \(userInfo)\n")
        
        let dic = userInfo as! NSDictionary
        
        print("dic : \(dic)")
        
        let img = dic["img"] as! String
        let link = dic["link"] as! String
        let text = dic["text"] as! String
        
        print(img)
        print(link)
        print(text)
        
        if let id = UserDefaults.standard.object(forKey: "ID"), let pw = UserDefaults.standard.object(forKey: "PW") {
            let storyboard = UIStoryboard.init(name : "Main", bundle : nil)
            
            if let url = dic["link"] as? String {
                if url != "" {
                    print("url: \(url)")
                    UserDefaults.standard.set(url, forKey: "push_url")
                    self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeController")
//                    if let topController = UIApplication.topViewController() {
//                        if let naviVC = storyboard.instantiateViewController(withIdentifier: "NTextController") as?  NavigationController {
//                        if let naviVC = storyboard.instantiateViewController(withIdentifier: "HomeController") as? HomeController {

//                            let config = WKWebViewConfiguration()
//                            config.userContentController.add(self, name: "getCompanyInfo")
//
//                            let wkWebView = WKWebView(frame: .zero, configuration: config)
//
//                            wkWebView.uiDelegate = self
//                            let token = UserDefaults.standard.object(forKey: "token") as! String
//                            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
//                            request.httpMethod = "POST"
//                            let postString = "id=\(id)&pw=\(pw)&token=\(token)&device=ios"
//                            request.httpBody = postString.data(using: .utf8)
//                            wkWebView.load(request)
//                            self.window?.addSubview(wkWebView)

//                            topController.present(naviVC, animated: false, completion: nil)
//                        }
//                    }
                }
            }
        }
        
        // 앱이 구동 중일 때 푸쉬가 올 때, 뱃지 컨트롤 가능.
        completionHandler([.alert, .badge, .sound])   // completionHandler 에 모든 일들을 넣어줘야 끝난다.  //completionHandler([])
    }
    
    // on Foreground/ Background & onDidBecomeActive 푸시 알람을 눌러서 앱이 켜질 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("\n[ FCM ] userInfo2 : \(userInfo)\n")
        
        let dic = userInfo as! NSDictionary
        
        print("dic : \(dic)")
        
        let img = dic["img"] as! String
        let link = dic["link"] as! String
        let text = dic["text"] as! String
        
        print(img)
        print(link)
        print(text)
        
        if let id = UserDefaults.standard.object(forKey: "ID"), let pw = UserDefaults.standard.object(forKey: "PW") {
            
            let storyboard = UIStoryboard.init(name : "Main", bundle : nil)
            
            if let url = dic["link"] as? String {
                if url != "" {
                    print("url: \(url)")
                    UserDefaults.standard.set(url, forKey: "push_url")
                    self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeController")
//                    if let topController = UIApplication.topViewController() {
//                        if let naviVC = storyboard.instantiateViewController(withIdentifier: "NTextController") as? NavigationController {
//                        if let naviVC = storyboard.instantiateViewController(withIdentifier: "HomeController") as? HomeController {

//                            let config = WKWebViewConfiguration()
//                            config.userContentController.add(self, name: "getCompanyInfo")

//                            let wkWebView = WKWebView(frame: .zero, configuration: config)
//
//                            wkWebView.uiDelegate = self
//                            let token = UserDefaults.standard.object(forKey: "token") as! String
//                            var request = URLRequest(url: URL(string: domain + loginSuccessURL)!)
//                            request.httpMethod = "POST"
//                            let postString = "id=\(id)&pw=\(pw)&token=\(token)&device=ios"
//                            request.httpBody = postString.data(using: .utf8)
//                            wkWebView.load(request)
//                            self.window?.addSubview(wkWebView)

//                            topController.present(naviVC, animated: false, completion: nil)
//                        }
//                    }
                }
            }
        }
        
        // 푸시착알람을 눌러서 앱이 켜질 때
        completionHandler()
    }
    
}

extension AppDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getCompanyInfo" {
            print(message.body)
            guard let scriptMessage = message.body as? String else {
//                basicAlert(target: self, title: "데이터 가져오기 실패", message: "다시 로그인을 해주시기 바랍니다")
                return
            }
            
            convertToDictionary(text: scriptMessage)
        }
    }
}

extension AppDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.evaluateJavaScript("getCompanyInfo()", completionHandler: nil)
    }
}

extension AppDelegate : MessagingDelegate {
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

