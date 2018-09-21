//
//  ViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/20/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    // MARK: properties
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginClick(_ sender: UIButton) {
        let user = self.emailText.text!
        let password = self.passwordText.text!
        print(user)
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
                         print(student["student_id"])
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
    
}

