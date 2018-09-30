//
//  UpdateViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/22/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    var student_id: Int? 
    @IBOutlet weak var img: UIImageView!
    
    var vectors = "[[1,1,1],[1,1,1]]"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(student_id)
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        self.img.addGestureRecognizer(tapGesture)
        self.img.isUserInteractionEnabled = true
    }
    @objc func tapImageView(){
        print("Something")
        let image = UIImagePickerController()
        image.delegate = self
        
        let alert = UIAlertController(title: "Choose Image", message: "Pick image from", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (_) in
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            image.allowsEditing = false
            
            self.present(image, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                image.sourceType = UIImagePickerControllerSourceType.camera
                //            image.allowsEditing = false
                self.present(image, animated: true, completion: nil)
            }else{
                print("camera not available")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (_) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.img.image = image
        }else {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
    @IBAction func onClickContinue(_ sender: Any) {
        let name = self.nameTextField.text!
        let birthday = self.birthdayTextField.text!
        
        if name == "" {
            let alert = UIAlertController(title: "Enter your Name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if birthday == "" {
            let alert = UIAlertController(title: "Enter your birthday ", message: "nn/tt/nnnn", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            let data : Parameters = ["student_id" : student_id!, "student_name" : name, "birthday" : birthday, "vectors" : vectors]
            Alamofire.request("\(url_api)/student_update", method: .post, parameters: data).response { (res) in
                print("res")
                if let d = res.data {
                    let json = JSON(d)
                    let statusCode = json["status"].intValue
                    if statusCode == 1 {
                        if let _ = self.navigationController {
                            self.navigationController?.popToRootViewController(animated: true)
                        }else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateInitialViewController()!
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        }
    }
    
}
