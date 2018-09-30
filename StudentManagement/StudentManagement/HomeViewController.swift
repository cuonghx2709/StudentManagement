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
        print(self.student!.studentID)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            print("abcd")
            if let vc = segue.destination as? UpdateViewController {
                vc.student_id = self.student?.studentID
            }
        }else if segue.identifier == "courses"{
            if let vc = segue.destination as? EnrolledTableViewController{
                vc.studentid = self.student?.studentID
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onLogoutClick(_ sender: UIButton) {
        let fm = FileManager.default
        let docurl = try! fm.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let url = docurl.appendingPathComponent("account.txt")
        try! fm.removeItem(at: url)
        if let vc = self.navigationController?.presentingViewController {
            vc.view.alpha = 1
            vc.dismiss(animated: true)
        }
        
    }
    
}
