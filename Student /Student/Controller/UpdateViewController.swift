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
import ImagePicker
import Photos

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImagePickerDelegate , UITextFieldDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btn: UIButton!
    
    var vectors = "[[1,1,1],[1,1,1]]"
    var vectors_Image : [[Decimal]] = []
    
    var vs : [String] = []
    var onKeyboardForTextField : UITextField!
    var tap : UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        self.img.addGestureRecognizer(tapGesture)
        self.img.isUserInteractionEnabled = true
        self.loadFaceNet()
        
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
    }
    @objc func tapImageView(){
        print("Something")
        
        var config = Configuration()

        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 3
        imagePicker.delegate = self
        imagePicker.galleryView.isHidden = true
        imagePicker.startOnFrontCamera = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func onClickContinue(_ sender: Any) {
        let name = self.nameTextField.text!
        let birthday = self.birthdayTextField.text!
        
        if name == "" {
            let alert = UIAlertController(title: "Enter your Name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if birthday == "" || !Utils.isValidDate(dateString: birthday) {
            let alert = UIAlertController(title: "Enter your birthday", message: "Format: dd/MM/yyyy", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            let id = Utils.getCurrentUserId()!
            var success = false
            for image in vectors_Image{
                if (image.count > 0){
                    success = true
                }
            }
            if vectors_Image.count == 0 {
                let alert = UIAlertController(title: "Select an image", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                async_main {
                    self.present(alert, animated: true, completion: nil)
                }
            }else if !success{
                let alert = UIAlertController(title: "Can't detect your image", message: "Select orther image", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                async_main {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
//                print(vectors_Image.description)
                print([[1.0,2.0,3.0],[1.2,2.2,3.3]].description)
                let data : Parameters = ["student_name" : name, "birthday" : birthday, "vectors" : vectors_Image.description
                ]
                Alamofire.request("\(url_api)/student/\(id)", method: .post, parameters: data).response { (res) in
                    print(res.response?.statusCode)
                    if let d = res.data {
                        let json = JSON(d)
                        let statusCode = json["status"].intValue
                        print(statusCode)
                        if statusCode == 1 {
                            Utils.saveCurrentUser(Utils.getCurrentUserId()!, self.vectors_Image.description, birthday,"none" , student_name: name)
                            if let _ = self.navigationController {
                                self.navigationController?.popToRootViewController(animated: true)
                            }else {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "Home")
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    class func getAssetImage(asset: PHAsset, size: CGSize = CGSize.zero) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        var assetImage: UIImage!
        var scaleSize = size
        if size == CGSize.zero {
            scaleSize = PHImageManagerMaximumSize
        }
        
        manager.requestImage(for: asset, targetSize: scaleSize, contentMode: .aspectFit, options: option) { (image, nil) in
            if let image = image {
                assetImage = image
            }
        }
        if assetImage == nil {
            manager.requestImageData(for: asset, options: option, resultHandler: { (data, _, orientation, _) in
                if let data = data {
                    if let image = UIImage.init(data: data) {
                        assetImage = image
                    }
                }
            })
        }
        return assetImage
    }
    
}

//let fNet = FaceNet()
//let fDetector = FaceDetector()


func rotateImage(image:UIImage) -> UIImage
{
    var rotatedImage = UIImage()
    switch image.imageOrientation
    {
    case .right:
        rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
        
    case .down:
        rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
        
    case .left:
        rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
        
    default:
        rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
    }
    
    return rotatedImage
}
extension UpdateViewController {
    @objc func loadFaceNet() {
        loadLastModel = { self.navigationController?.view.addActivityIndicatorOverlay(){ remove in
                fnet.load()
                self.nameTextField.text = Utils.getCurrentUser()?.name
                self.birthdayTextField.text = Utils.getCurrentUser()?.birthday
                print(Utils.getCurrentUser()?.name)
                remove()
            }
        }
        loadLastModel()
        
    }
    @objc func identifyFace(uiImage: UIImage)-> [Double]{
        guard let cgImage = uiImage.cgImage else { return [] }
        guard let f = fDetector.extractFaces(frame: CIImage(cgImage: cgImage)).first else { return [] }
        return fnet.run(image: f.face)
    }
}

extension UpdateViewController {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapp")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

//        cloudinary?.createUrl().generate("sample.jpg")
        
        let imgs = AssetManager.resolveAssets(imagePicker.stack.assets, size: CGSize(width: 720, height: 960))
        let imgs2 = AssetManager.resolveAssets(imagePicker.stack.assets, size: CGSize(width: 720, height: 1280))
        
        imagePicker.dismiss(animated: true) {
            if let nav = self.navigationController {
                let wait = { self.navigationController?.view.addActivityIndicatorOverlay(){ remove in
                    self.img.image = imgs.last
                    for i in 0..<images.count{
                        let image = images[i]
                        print(image)
                        if image.size.width / image.size.height == 3/4 {
                            let vector = self.identifyFace(uiImage: imgs[i])
                            print(vector.count)
                            let v = vector.map({ (a : Double) -> Decimal in
                                let a = a.rounded(toPlaces: 7)
                                return Decimal.init(string: a.description)!
                            })
                            
                            self.vectors_Image.append(v)
                        }else{
                            let vector = self.identifyFace(uiImage: image)
                            print(vector.count)
                            let v = vector.map({ (a : Double) -> Decimal in
                                let a = a.rounded(toPlaces: 7)
                                return Decimal.init(string: a.description)!
                            })
                            self.vectors_Image.append(v)
                        }
                    }
                    remove()
                    }
                }
                wait()
            }else {
                self.view.addActivityIndicatorOverlay(){ remove in
                    self.img.image = imgs.last
                    for i in 0..<images.count{
                        let image = images[i]
                        print(image)
                        if image.size.width / image.size.height == 3/4 {
                            let vector = self.identifyFace(uiImage: imgs[i])
                            print(vector.count)
                            let v = vector.map({ (a : Double) -> Decimal in
                                let a = a.rounded(toPlaces: 7)
                                return Decimal.init(string: a.description)!
                            })
                            
                            self.vectors_Image.append(v)
                        }else{
                            let vector = self.identifyFace(uiImage: image)
                            print(vector.count)
                            let v = vector.map({ (a : Double) -> Decimal in
                                let a = a.rounded(toPlaces: 7)
                                return Decimal.init(string: a.description)!
                            })
                            self.vectors_Image.append(v)
                        }
                    }
                    remove()
                }
            }
            
            
        }
        print("done")
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true) {
            
        }
        print("cancel")
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
//        self.scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-280-|", metrics: nil, views: ["v0" : self.btn]))
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
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let filteredConstraints = self.btn.superview?.constraints.filter { $0.identifier == "bottom" }
        if let constrain = filteredConstraints?.first {
            // DO YOUR LOGIC HERE
            if notification.name == Notification.Name.UIKeyboardWillShow {
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    let keyboardHeight = keyboardSize.height
                    print(keyboardHeight)
                    constrain.constant = keyboardHeight + 20
                    self.view.layoutIfNeeded()
                }
            }else {
                constrain.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
}

