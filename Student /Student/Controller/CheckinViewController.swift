//
//  CheckinViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 10/6/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseStorage
import CoreLocation

class CheckinViewController: UIViewController {
    
    var vectors : [[Double]] = []
    var firstDetect = true
    var tmp = true
    var closeImageView: UIImageView!
    var switchImageView: UIImageView!
    let locationManager = CLLocationManager()
    var currentLocation : CLLocationCoordinate2D!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        setupCam()
        
        setupUI()
        
        showSelectionMenu()
        
        requireLocation()
    }
    func requireLocation(){
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getdata(remove : @escaping() -> Void){
        if (Utils.getCurrentUser()?.vectors == "") {
            let alert = UIAlertController(title: "Dont have any data image", message: "Update image in setting before checkin", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            let array = Utils.getCurrentUser()!.vectors
//            print("cuonghx" + array)
            
            let data = array.data(using: .utf8)!
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("abcdef")
                if let arr = json as? [[Double]] {
                    print(arr.count)
                    self.vectors = arr
                    if (arr.count == 1 && arr[0].count <= 0){
                        let alert = UIAlertController(title: "Dont have any data image", message: "Update image in setting before checkin", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        }
        remove()
    }
    @IBOutlet weak var label: UILabel!
    
    @objc func setupUI(){
        
        //drawing transparency
        self.label.text = "Vui lòng giữ yên thẳng mặt!"
        transparency = Transparency(frame: view.bounds)
        view.addSubview(transparency)
        
        let image = UIImage(named: "close")
        closeImageView = UIImageView(image: image?.addImagePadding(x: 20, y: 20))
        closeImageView.isUserInteractionEnabled = false
        closeImageView.isHidden = true
        
        view.addSubview(closeImageView)
        closeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(45)]", metrics: nil, views: ["v0" : closeImageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(45)]", metrics: nil, views: ["v0" : closeImageView]))
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCancelClick))
        closeImageView.addGestureRecognizer(tap)
        
        
        let cameraSwitch = UIImage(named: "cameraSwitch")
        switchImageView = UIImageView(image: cameraSwitch?.addImagePadding(x: 15, y: 15))
        switchImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchImageView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(45)]|", metrics: nil, views: ["v0" : switchImageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(45)]", metrics: nil, views: ["v0" : switchImageView]))
        
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(onSwitchCamera))
        switchImageView.addGestureRecognizer(tapCamera)
        
        switchImageView.isUserInteractionEnabled = false
        switchImageView.isHidden = true
        
    }
    
    var check = true
    @objc func onSwitchCamera(){
        print("switch camera")
        self.toggleCam()
    }
    
    @objc func onCancelClick(){
        print("some thing")
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

//MARK: -
enum Model { case yolo; case facenet; case inception; case jetpac; case none }
var currentModel : Model = .none

//MARK: FaceNet
let fnet = FaceNet()
//let kNN = KNN()
var fnetThreshold = 0.75
let fDetector = FaceDetector()

var detectedFaces : FaceOutput = []

extension CheckinViewController {
    
    @objc func loadFacenetModel(){
        
        fnet.load()
        currentModel = .facenet
        
        fnetThreshold = 0.75
        
        showDrawing()
    }
    
    @objc func detectFaces(frameImage: CIImage){
        
        detectedFaces = fDetector.extractFaces(frame: frameImage)
        
        
        drawBoxes(detectedFaces.map { f in
            
            
            guard dslots.contains(where:{ $0.value.count>0 }) else { return (f.box, UIColor.cyan, (""+(f.smile ? " 😀 " : "")) as NSString) }
            
            let features = fnet.run(image: f.face)
            print(features)
            
            let slots = dslots.map { ($0.value.map { $0.features }, Array(repeating: $0.key.tag, count: $0.value.count)) }
            
//            let dist = FaceNet.l2distance(features, features)
            
//            let (pred, dist) = kNN.run(x: features, samples: slots.flatMap { $0.0 }, classes: slots.flatMap { $0.1 })
            
//            guard pred > -1 else { return (f.box, UIColor.cyan, "?!") }
            
//            print("pred", pred)
//            print("min l2 distance", dist)
            
//            let text = String(format: "%.02f", dist)+(f.smile ? " 😀 " : "")
            
//            if dist<fnetThreshold {
//                return (f.box, colorPalette[pred-1], text as NSString)
//            } else {
                return (f.box,  UIColor.cyan, "cuonghx" as NSString)
//            }
        })
//        let image = UIImage(named: "img.jpg")!
//        let i = CIImage(image: image)
//        let detect = fDetector.extractFaces(frame: i!)
        
        if let face = detectedFaces.first{
            let d = fnet.run(image: face.face)
            print(d.count)
// RUN TIME REAL CHECK IN
            var distance: Double = 10;
            for v in vectors {
                if v.count > 0 {
                    let dist = FaceNet.l2distance(d, v)
                    if dist < distance {
                        distance = dist
                    }
                }
            }
            
            if tmp && distance < 0.7{
                tmp = false;
                let id = Utils.getCurrentUserId()!
                print("cuonghx2709 \(self.currentLocation.longitude)")
                let data : Parameters = ["student_id" : id, "lat" : "\(self.currentLocation.latitude)", "long" : "\(self.currentLocation.longitude)"]
                ///check_in/
                Alamofire.request("\(url_api)/check_in", method: .post, parameters: data).response(completionHandler: { (res) in
                    if let err = res.error {
                        print(err.localizedDescription)
                        let alert = UIAlertController(title: err.localizedDescription, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { (_) in
                            async_main({
                                self.navigationController?.popViewController(animated: true)
                                self.navigationController?.setNavigationBarHidden(false, animated: true)
                            })
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        if let data  = res.data {
                            let json = JSON(data)
                            if json["status"].intValue == -1 {
                                let alert = UIAlertController(title: "Can't check in now!", message: "There are no courses for your location!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (_) in
                                    self.navigationController?.popViewController(animated: true)
                                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                                }))
                                async_main({
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }else if (json["status"].intValue == -2){
                                let alert = UIAlertController(title: "Already checkin today!", message: nil , preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (_) in
                                    self.navigationController?.popViewController(animated: true)
                                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                                }))
                                async_main({
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }else {
                                print(json)
                                let insertID = json["insertId"].intValue
                                let courseID = json["course_id"].intValue
                                self.uploadPhoto(insertID, frameImage, courseID)
                            }
                        }
                    }
                })
            }
            
            // Check in upload fireStore
            if self.firstDetect{
                async_main {
                    UIView.animate(withDuration: 200, animations: {
                        self.closeImageView.isUserInteractionEnabled = true
                        self.closeImageView.isHidden = false
                        self.switchImageView.isUserInteractionEnabled = true
                        self.switchImageView.isHidden = false
                    })
                }
                self.firstDetect = !self.firstDetect
            }
            async_main {
                self.label.text = String(format:"%.5f", distance)
                self.label.textColor = UIColor.blue
            }
            print(distance)
            
        }
    }
    @objc func identifyFace(uiImage: UIImage)-> [Double]{
        guard let cgImage = uiImage.cgImage else { return [] }
        guard let f = fDetector.extractFaces(frame: CIImage(cgImage: cgImage)).first else { return [] }
        return fnet.run(image: f.face)
    }
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    func uploadPhoto(_ insertID : Int, _ frameImage : CIImage, _ course_id : Int){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let mountainImagesRef = storageRef.child("course_\(course_id)/\(Utils.getCurrentUserId()!)_\(components.day!)-\(components.month!).jpg")
        let image = self.convert(cmage: frameImage)
        let dataTest = UIImageJPEGRepresentation(image, 0.5)
        let uploadTask = mountainImagesRef.putData(dataTest!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print(error?.localizedDescription)
                return
            }
            print(metadata)
            mountainImagesRef.downloadURL { url, error in
                if let error = error {
                    print(error)
                } else {
                    print(url!.absoluteString)
                    let parameter : Parameters = ["upload_link" : url!.absoluteString]
                    Alamofire.request("\(url_api)/check_in/\(insertID)", method: .post, parameters: parameter).response(completionHandler: { (res) in
                        if let data = res.data {
                            let json = JSON(data)
                            print(json)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    //                let url = URL(string: url)
//                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    print(UIImage(data: data!))
                }
            }
        }
        uploadTask.resume()
        
    }
    
}

//MARK: -
var modelLabel = UILabel()
var timeLabel = UILabel()
var finalTask : (()->Void)?

//MARK: Menu UI
var loadLastModel: ()->Void = {}

extension CheckinViewController {
    
    @objc func showSelectionMenu() {
        
        loadLastModel = { self.view.addActivityIndicatorOverlay(){ remove in
            
            self.loadFacenetModel()
        
            frameProcessing = { frame in
                self.detectFaces(frameImage: frame)
                oneShot(&finalTask)
            }
            self.getdata(remove: remove)
            }
        }
        loadLastModel()
    }
}

//MARK: Data Slots UI

typealias DataSlots = [UIImageView : [(features: [Double], label: String, photo: UIImage)]]
var dslots = DataSlots()

//MARK: Drawing Transparency
var transparency = Transparency()
var colorPalette = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.magenta]

extension CheckinViewController {
    
    func drawBoxes(_ boxes: [(CGRect, UIColor, NSString)]){
        
        async_main {
            transparency.boxList.removeAll()
            transparency.boxList = boxes
            transparency.setNeedsDisplay()
        }
    }
    
    @objc func showDrawing(){
        async_main {
            transparency.drawing = true
            transparency.setNeedsDisplay()
        }
    }
}
extension CheckinViewController {
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopCam()
        fnet.clean()
//        kNN.clean()
    }
}
extension CheckinViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        let coordinate0 = CLLocation(latitude: 20.996764, longitude: 105.762769)
//        let distanceInMeters = coordinate0.distance(from: manager.location!)
//        print("cuognhx \(distanceInMeters)")
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.currentLocation = locValue
    }
}
