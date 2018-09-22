//
//  ViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/20/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: properties
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check user
        let fm = FileManager.default
        let docsurl = try! fm.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let urlfile = docsurl.appendingPathComponent("account.txt")
        if let accountData = try? Data(contentsOf: urlfile){
            if let acc  = NSKeyedUnarchiver.unarchiveObject(with: accountData) as? Account{
                print(acc.user)
                print(acc.password)
//                loginwith(user: acc.user, password: acc.password)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
        
//        let data : Parameters = ["student_id" : 8, "student_name" : "cuonghx2709"]
//        Alamofire.request("http://localhost:8080/", method: .post ,parameters: data, encoding: JSONEncoding.default).response { (respone) in
//            print("respone")
//        }
//        let acc = Account(user: "abcd", password: "123")
//        let parameters: Parameters = [
//            "student_id": 8,
//            "vectors" : acc
//        ]
////        let par: Parameters = ["a": [1, 2, 3]]
//        Alamofire.request("http://localhost:8080", method: .post, parameters: ["foo": [1, 2], "abc" : 8], encoding: CustomPostEncoding())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginClick(_ sender: UIButton) {
        let user = self.emailText.text!
        let password = self.passwordText.text!
        print(user)
        loginwith(user: user, password: password)
    }
    
    func loginwith(user : String, password : String){
        var url = URLComponents(string: "\(url_api)/student_login")
        url?.queryItems = [URLQueryItem(name: "email", value: user), URLQueryItem(name: "password", value:password)]
        let request = URLRequest(url: (url?.url)!)
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print("Error")
            }else {
                if let d = data {
                    let student = JSON(d)
                    if student == JSON.null {
                        print("null")
                        
                        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        let alertController = UIAlertController(title: "Wrong email or password", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(action)
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }else {
                        if let vector = student["vectors"].string {
                            print(vector)
                            let arr = vector.components(separatedBy: ",[")
                            let conv = arr.map({ (string : String) -> [Int] in
                                let editedText = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                                print(editedText)
                                let arrInt = editedText.components(separatedBy: ",").map({ (s : String) -> Int in
                                    if let n = Int(s){
                                        return n
                                    }
                                    return 0;
                                })
                                return arrInt
                            })
                            print(conv)
                        }
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "Home");
                        
                        DispatchQueue.main.async {
                            vc.view.alpha = 0;
                            self.present(vc, animated: true, completion:{
                                let fm = FileManager.default
                                let docsurl = try! fm.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
                                let account = Account(user: user, password: password)
                                let saveData = NSKeyedArchiver.archivedData(withRootObject: account)
                                let urlfile = docsurl.appendingPathComponent("account.txt")
                                try! saveData.write(to: urlfile, options: .atomic)
                                
                                let accountData = try! Data(contentsOf: urlfile)
                                let acc  = NSKeyedUnarchiver.unarchiveObject(with: accountData) as! Account
                                print(acc.user)
                                
                            })
                            UIView.animate(withDuration: 3000) {
                                vc.view.alpha = 1
                                self.view.alpha = 0
                            }
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
    
    
    @IBAction func ResClick(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterScr");
        vc.view.alpha = 0;
        self.present(vc, animated: false, completion: nil)
        UIView.animate(withDuration: 3000) {
            vc.view.alpha = 1
            self.view.alpha = 0
        }
    }
    
    // MARK: textfile Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        // Try to find next responder
        if let nextResponder: UIResponder = textField.superview!.viewWithTag(nextTag){
            // Found next responder, so set it.
            nextResponder.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
//            loginClick(UIButton())
        }
        return false;
    }
    
}

