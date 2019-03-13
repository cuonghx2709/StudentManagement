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
import TransitionButton

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: properties
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var onKeyboardForTextField : UITextField!
    var tap : UITapGestureRecognizer!
    var lg : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check user
        self.logo.isHidden = true
        self.emailText.alpha = 0
        self.passwordText.alpha = 0
        self.registerButton.alpha = 0
        self.loginButton.alpha = 0
        let ui = UIImageView(frame: CGRect(x: 0, y: 0, width: 115, height: 115))
        ui.center = self.view.center
        ui.image = UIImage(named: "logo")
        self.lg = ui
        self.view.addSubview(self.lg)
        self.loginButton.cornerRadius = self.loginButton.frame.height / 2
        self.registerButton.layer.cornerRadius = self.registerButton.frame.height / 2
        
        UIView.animate(withDuration: 0.5, animations: {
            self.lg.center = CGPoint(x: self.view.center.x , y: self.logo.center.y)
//            self.view.layoutIfNeeded()
            self.emailText.alpha = 1
            self.passwordText.alpha = 1
            self.registerButton.alpha = 1
            self.loginButton.alpha = 1
        }) { (_) in
            self.lg.removeFromSuperview()
            self.logo.isHidden = false
        }
    }

    @IBAction func loginClick(_ sender: TransitionButton) {
        sender.startAnimation()
        let user = self.emailText.text!
        let password = self.passwordText.text!
        print(user)
        if (self.emailText.isFirstResponder){
            self.emailText.resignFirstResponder()
        }else if (self.passwordText.isFirstResponder){
            self.passwordText.resignFirstResponder()
        }
        loginByAuth(user, password, sender)
    }
    
    
    func loginByAuth(_ email : String, _ password : String, _ button : TransitionButton){
//        self.view.addActivityIndicatorOverlay { (remove) in
        
            if (email == "" || password == "") {
//                remove()
                let alert = UIAlertController(title: "Email and password not null", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel , handler: { (_) in
                    self.emailText.becomeFirstResponder()
                }))
                button.stopAnimation(animationStyle: .shake, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            }else {
                let parameter : Parameters = ["email" : email , "password" : password]
                Alamofire.request("\(url_api)/login", method: .post , parameters: parameter).response(completionHandler: { (res) in
                    if res.response?.statusCode == 200 {
//                        remove()
                        if let data = res.data {
                            let json = JSON(data)
                            print(json)
                            if (json["status"].intValue == -1) {
                                let alert = UIAlertController(title: "Wrong email or password", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "ok", style: .cancel , handler: { (_) in
                                    
                                }))
                                button.stopAnimation(animationStyle: .shake, completion: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }else {
                                let student = json["student"]
                                Utils.saveCurrentUser(student["student_id"].intValue, student["vectors"].stringValue, student["birthday"].stringValue, student["email"].stringValue, student_name: student["student_name"].stringValue)
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                                async_main({
                                    button.stopAnimation(animationStyle: .expand, completion: {
                                        self.present(vc, animated: true, completion: nil)
                                    })
                                    
                                })
                                
                            }
                        }
                    }else {
                        let alert = UIAlertController(title: "Check your internet", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel , handler: { (_) in
                        }))
                        async_main({
                            button.stopAnimation(animationStyle: .shake, completion: {
                                self.present(alert, animated: true, completion: nil)
                            })
                        })
                    }
                })
            }
//        }
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
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        print("Forgot password")
        let alert = UIAlertController(title: "Enter your email", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (tf) in
            
        }
        func handler (_ act : UIAlertAction){
            let tf = alert.textFields![0]
            if let text = tf.text {
                let data : Parameters = ["email" : text]
                Alamofire.request("\(url_api)/student/forgotpassword", method: .post, parameters: data).response { (res) in
                    if let err = res.error {
                        print(err)
                    }else{
                        let alert = UIAlertController(title: "Done!", message: "Please check your email with new password.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        async_main({
                                self.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tap = UITapGestureRecognizer(target: self, action: #selector(tapOutSideKeyboard))
        self.view.addGestureRecognizer(self.tap)
        self.onKeyboardForTextField = textField
        print("begin")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("end")
        self.view.removeGestureRecognizer(self.tap)
        self.onKeyboardForTextField = nil
        if self.tap != nil {
            self.view.removeGestureRecognizer(self.tap)
            self.tap = nil
        }
        return true
    }
    
    @objc func tapOutSideKeyboard(){
        print("Some thing")
        self.onKeyboardForTextField.resignFirstResponder()
        
        self.onKeyboardForTextField = nil
        if self.tap != nil {
            self.view.removeGestureRecognizer(self.tap)
            self.tap = nil
        }
    }
}

