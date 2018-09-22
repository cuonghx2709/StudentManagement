//
//  RegisterViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/22/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onCreateClick(_ sender: Any) {
        let email = self.email.text!
        let password = self.password.text!
        if password == "" || email == "" {
            let alert = UIAlertController(title: "Error", message: "Enter your password/email", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alert.addAction(action)
            
            self.present(alert, animated: true) {
                self.password.text = "";
                self.confirmPassword.text = "";
            }
        }else if password != self.confirmPassword.text {
            let alert = UIAlertController(title: "Error", message: "Password does not match the confirm password", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alert.addAction(action)
            
            self.present(alert, animated: true) {
                self.password.text = "";
                self.confirmPassword.text = "";
            }
        }else {
//            var url = URLComponents(string: "\(url_api)/student_register")
//            url?.queryItems = [URLQueryItem(name: "email", value: email), URLQueryItem(name: "password", value: password)]
//            var request = URLRequest(url: (url?.url)!)
//            request.httpMethod = "GET"
//
//            let sessionConfiguration = URLSessionConfiguration.default
//            let session = URLSession(configuration: sessionConfiguration)
//            let task = session.dataTask(with: request) { (data, res, err) in
            
//                print(data)
//                var std_id = 0;
//                print(data?.base64EncodedString())
//                let value = data!.withUnsafeBytes { (ptr: UnsafePointer<Double>) -> Double in
//                    return ptr.pointee
//                }
//                print(data! as NSData)
//                print(value)
//                if std_id == -1 {
//                    print("errr")
//                }else {
//                    print("success \(std_id)")
//                }
//            }
//            task.resume()
            Alamofire.request("\(url_api)/student_register?email=\(email)&password=\(password)").responseJSON { (res) in
                
                let status = res.description
                print(status)
                let id = status.substring(from: status.index(after: status.index(of: " ")!))
                let i = Int(id)
                print(i)
                if id == "-1" {
                    let alert = UIAlertController(title: "Err", message: "Email already exists", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    print("sucess")
                    let i = Int(id);
                    print(i)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "updateScreen") as! UpdateViewController
                    vc.student_id = i
                    self.present(vc, animated: true, completion: nil)
                    let fm = FileManager.default
                    let docsurl = try! fm.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                    let account = Account(user: email, password: password)
                    let saveData = NSKeyedArchiver.archivedData(withRootObject: account)
                    let urlfile = docsurl.appendingPathComponent("account.txt")
                    try! saveData.write(to: urlfile, options: .atomic)
                }
            }
        }
    }
    
}
