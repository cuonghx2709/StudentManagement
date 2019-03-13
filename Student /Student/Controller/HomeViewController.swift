//
//  HomeViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/24/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    var student : User?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Utils.subscriptMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            print("abcd")
            if let vc = segue.destination as? UpdateViewController {
            }
        }else if segue.identifier == "courses"{
            if let vc = segue.destination as? EnrolledTableViewController{
                vc.studentid = self.student?.studentID
            }
        }else if segue.identifier == "checkin"{
            
        }
    }
    @IBAction func onLogoutClick(_ sender: UIButton) {
        Utils.unsubscriptMessage()
        Utils.removeCurrentUserID()
        
        
        if let vc = self.navigationController?.presentingViewController {
            vc.view.alpha = 1
            vc.dismiss(animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.present(vc!, animated: true, completion: nil)
        }
        
    }
    
}
