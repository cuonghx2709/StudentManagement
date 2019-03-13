//
//  NavViewController.swift
//  Student
//
//  Created by cuonghx on 12/7/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//
import UserNotifications
import UIKit
import SwiftyJSON

class NavViewController: UINavigationController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handlerReceiveRemoteNotification(_:)), name: NSNotification.Name("receiveRemoteNotification"), object: nil)
        print("abcd")
    }
    
    @objc func handlerReceiveRemoteNotification(_ notificaton : NSNotification){
        if let userInfor = notificaton.userInfo {
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print full message.
//        print("handel")
//        print(userInfo)
//        print(userInfo["course_id"])
        if let context = userInfo["context"] as? String, context == "message"{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let presentViewController = storyBoard.instantiateViewController(withIdentifier: "chatlog") as! ChatLogCollectionViewController
//            presentViewController
            if let _ = self.topViewController as? ChatLogCollectionViewController {
                self.popToRootViewController(animated: false)
            }
            print("cuonghx \(userInfo["course_id"])")
            presentViewController.courseID = Int(userInfo["course_id"] as! String)!
            self.pushViewController(presentViewController, animated: true)
        }else if let context = userInfo["context"] as? String, context == "checkin"{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let presentViewController = storyBoard.instantiateViewController(withIdentifier: "CheckinViewController") as! CheckinViewController
            self.pushViewController(presentViewController, animated: true)
        }
        completionHandler()
    }
}

