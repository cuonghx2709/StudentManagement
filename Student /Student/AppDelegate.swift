//
//  AppDelegate.swift
//  StudentManagement
//
//  Created by cuonghx on 9/20/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import Alamofire
import SwiftyJSON
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    static var showmenu: Bool = false
    static let menu = ["Home", "Enroll Course", "Check in", "Setting", "Logout"]
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        if let _ = Utils.getCurrentUserId() {
            self.window = self.window ?? UIWindow()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            var viewController = UIViewController()
            if let user = (launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]) {
                viewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! NavViewController
//                UserDefaults.standard.set(user["course_id"], forKey: "course_id")
            }else{
                viewController = storyBoard.instantiateViewController(withIdentifier: "Home") // User not tap notificaiton
            }
//            let id = UserDefaults.standard.integer(forKey: "course_id")
//                print("cuonghx2709 \(Utils.getCourseID())")
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("some thing")
        print(userInfo)
        print("APN recieved")
        // print(userInfo)
        
        let state = application.applicationState
        switch state {
            
        case .inactive:
            print("Inactive")
            
        case .background:
            print("Background")
            // update badge count here
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            
        case .active:
            print("Active")
            
        }
        NotificationCenter.default.post(name: NSNotification.Name("receiveRemoteNotification"), object: nil, userInfo: userInfo)
    }
}

