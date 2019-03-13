//
//  EnrolledTableViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/30/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FirebaseMessaging

class EnrolledTableViewController: UITableViewController {
    
    var studentid : Int?
    var courses = [Course]()
    var reloadAble = true

    @IBOutlet weak var moreButton: UIBarButtonItem!
    override func viewWillAppear(_ animated: Bool) {
        if (reloadAble) {
            getData()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell Courses")
        self.navigationItem.rightBarButtonItem?.action = #selector(more)
        self.navigationItem.rightBarButtonItem?.target = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    @objc func handleRefresh (_ refreshControl : UIRefreshControl){
        getData()
        refreshControl.endRefreshing()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.reloadAble = true
    }
    
    @objc func more(){
        print("abcd")
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        alert.addAction(UIAlertAction(title: "Add Course", style: UIAlertActionStyle.default, handler: { (_) in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "UnisViewController")
//            self.navigationController?.pushViewController(vc, animated: true)
//        }))
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.destructive, handler: { (_) in
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.done))
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Add course by Code", style: UIAlertActionStyle.default, handler: { (_) in
            let al = UIAlertController(title: "Enter your code!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            al.addTextField(configurationHandler: { (tf) in
                
            })
            func hander(_ act : UIAlertAction){
                let tf = al.textFields![0]
                if let text = tf.text{
                    Alamofire.request("\(url_api)/course/code/\(text)").response(completionHandler: { (res) in
                        if let data = res.data {
                            let json = JSON(data)
                            if json.isEmpty {
                                let alert = UIAlertController(title: "Can't find this code", message: "Please enter a valid code", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                                async_main({
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }else {
                                let alert = UIAlertController(title: "Would you want to enroll in this course?", message: "\(json["course_name"].stringValue)", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
                                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (_) in
                                    let parameter: Parameters = ["student_id" : Utils.getCurrentUserId()! , "course_id" : json["course_id"].stringValue]
                                    let course_id = json["course_id"].stringValue
                                    Alamofire.request("\(url_api)/enroll", method: .post, parameters: parameter).response(completionHandler: { (res) in
                                        print("something")
                                        if let data = res.data {
                                            let json = JSON(data)
                                            if json["status"].intValue == -1 {
                                                print("cuonghx")
                                                let alert = UIAlertController(title: "You have already registered for this course", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                                async_main({
                                                    self.present(alert, animated: true, completion: nil)
                                                })
                                            }else {
                                                let alert = UIAlertController(title:"Successfully enroll this course", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style:
                                                    UIAlertActionStyle.default, handler: { (_) in
                                                    self.getData()
                                                    Messaging.messaging().subscribe(toTopic: "\(course_id)") { (err) in
                                                            print("subcript to \(course_id) topic")
                                                        }
                                                }))
                                                async_main({
                                                    self.present(alert, animated: true, completion: nil)
                                                })
                                            }
                                        }
                                    })
                                }))
                                async_main({
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        }
                    })
                }
            }
             al.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
            al.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: hander))
            async_main({
                self.present(al, animated: true, completion: nil)
            })
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func done() {
        self.tableView.setEditing(false, animated: true)
//         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.done))
        let btn = UIBarButtonItem(image: UIImage(named: "more"), style: .plain , target: self, action: #selector(more))
        self.navigationItem.rightBarButtonItem = btn
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self.tableView.isEditing ? UITableViewCellEditingStyle.delete : UITableViewCellEditingStyle.none
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let course = self.courses[indexPath.row]
            self.view.addActivityIndicatorOverlay { (remove) in
                Alamofire.request("\(url_api)/unroll", method: .post, parameters: ["student_id" : Utils.getCurrentUserId()!, "course_id" : course.id]).response(completionHandler: { (res) in
                    remove()
                    if let data = res.data {
                        let json = JSON(data)
                        if (json["status"].intValue == 1){
                            let course = self.courses.remove(at: indexPath.row)
                            tableView.performBatchUpdates({
                                tableView.deleteRows(at:[indexPath], with: .automatic)
                            }) {_ in
                                Utils.unsubcriptionMessageCourse(course.id)
                            }
                        }else {
                            let alert = UIAlertController(title: "Can't unroll this course now!", message: "Please try again later", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                })
            }
           
        default: break
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatlog") as! ChatLogCollectionViewController
        vc.courseID = courses[indexPath.row].id
//        Utils.saveCourseID(courses[indexPath.row].id)
        vc.title = courses[indexPath.row].name
        async_main {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.courses.count
    }
    
    func getData(){
        
        let id = Utils.getCurrentUserId()!
        print("cuonghx \(id)")
        
        self.navigationController?.view.addActivityIndicatorOverlay { (remove) in
            Alamofire.request("\(url_api)/enroll/\(id)").response { (res) in
                remove()
                self.courses = [Course]()
                if let err = res.error {
                    print(err)
                    if let nameArray = UserDefaults.standard.array(forKey: "course_name_array"), let courseIDArray = UserDefaults.standard.array(forKey: "course_id_array"), (nameArray.count == courseIDArray.count) {
                        for index in 0..<nameArray.count {
                            let course = Course(name: nameArray[index] as! String, id: courseIDArray[index] as! Int)
                            self.courses.append(course)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }else  if let data = res.data {
                    let json = JSON(data).arrayValue
                    //                print(json)
                    var nameArray: [String] = []
                    var courseIDArray : [Int] = []
                    for index in json {
                        let course = Course(name: index["course_name"].stringValue, id: index["course_id"].intValue)
                        nameArray.append(index["course_name"].stringValue)
                        courseIDArray.append(index["course_id"].intValue)
                        self.courses.append(course)
                    }
                    UserDefaults.standard.set(nameArray, forKey: "course_name_array")
                    UserDefaults.standard.set(courseIDArray, forKey: "course_id_array")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
       
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell Courses", for: indexPath)
        let d = self.courses[indexPath.row]
        cell.textLabel?.text = d.name
        return cell
    }
    
}
