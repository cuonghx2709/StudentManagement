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
import TransitionButton

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var SignIn: UIButton!
    @IBOutlet weak var createBtn: TransitionButton!
    
    var onKeyboardForTextField : UITextField!
    var tap : UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.SignIn.isUserInteractionEnabled = true
        self.createBtn.cornerRadius = self.createBtn.frame.height / 2
    }

    @IBAction func CancelButton(_ sender: UIButton) {
        if let vc = self.presentingViewController {
            vc.dismiss(animated: false, completion: nil)
            UIView.animate(withDuration: 1000) {
                vc.view.alpha = 1;
            }
        }
        
    }
    @IBAction func onCreateClick(_ sender: TransitionButton) {
        sender.startAnimation()
        if (self.email.isFirstResponder){
            self.email.resignFirstResponder()
        }else if (self.password.isFirstResponder){
            self.password.resignFirstResponder()
        }else if (self.confirmPassword.isFirstResponder){
            self.confirmPassword.resignFirstResponder()
        }
        let email = self.email.text!
        let password = self.password.text!
        if password == "" || email == "" {
            let alert = UIAlertController(title: "Error", message: "Enter your password/email", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alert.addAction(action)
            sender.stopAnimation(animationStyle: .shake) {
                self.present(alert, animated: true) {
                    self.password.text = "";
                    self.confirmPassword.text = "";
                }
            }
        }else if !Utils.isValidEmail(testStr: email) {
            let alert = UIAlertController(title: "Email fromat is incorrect", message: "Please type your email address in the format yourname@exmaple.com", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alert.addAction(action)
            sender.stopAnimation(animationStyle: .shake) {
                self.present(alert, animated: true) {
                    self.password.text = "";
                    self.confirmPassword.text = "";
                }
            }
        }else if password != self.confirmPassword.text{
            let alert = UIAlertController(title: "Error", message: "Password does not match the confirm password", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alert.addAction(action)
            sender.stopAnimation(animationStyle: .shake) {
                self.present(alert, animated: true) {
                    self.password.text = "";
                    self.confirmPassword.text = "";
                }
            }
        }else{
            let data : Parameters = ["email" : email, "password" : password]
            Alamofire.request("\(url_api)/student", method: .post , parameters: data).response(completionHandler: { (res) in
                if res.response?.statusCode == 200 {
                    if let data = res.data{
                        let json = JSON(data)
                        let status = json["status"].intValue
                        if status == -1 {
                            let alert = UIAlertController(title: "Email already exists", message: "", preferredStyle: UIAlertControllerStyle.alert)
                            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (_) in
                                self.email.becomeFirstResponder()
                            })
                            alert.addAction(action)
                            sender.stopAnimation(animationStyle: .shake) {
                                self.present(alert, animated: true) {
                                    self.password.text = "";
                                    self.confirmPassword.text = "";
                                }
                            }
                        }else {
                            let id = json["student_id"].intValue
                            print(id)
                            Utils.saveCurrentUserID(id)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "updateScreen") as! UpdateViewController
                            sender.stopAnimation(animationStyle: .expand) {
                                self.present(vc, animated: true)
                            }
                            
                        }
                    }
                }else if res.response?.statusCode == 400 {
                    let alert = UIAlertController(title: "Email already exists", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (_) in
                        self.email.becomeFirstResponder()
                    })
                    alert.addAction(action)
                    
                    sender.stopAnimation(animationStyle: .shake) {
                        self.present(alert, animated: true, completion: {
                            self.password.text = "";
                            self.confirmPassword.text = "";
                        })
                    }
                }else {
                    let alert = UIAlertController(title: "Please check your network connection", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (_) in
//                        self.email.becomeFirstResponder()
                    })
                    alert.addAction(action)
                    
                    sender.stopAnimation(animationStyle: .shake) {
                        self.present(alert, animated: true, completion: {
                            self.password.text = "";
                            self.confirmPassword.text = "";
                        })
                    }
                }
            })
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
