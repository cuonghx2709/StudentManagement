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

class EnrolledTableViewController: UITableViewController {
    
    var studentid : Int?
    var courses = [Course]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        let buttonAdd = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add , target: self, action: #selector(addCourse))
//        self.navigationItem.rightBarButtonItem = buttonAdd
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell Courses")
        
        getData()
        
    }
    
//    @objc func addCourse(){
//
//    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let course = self.courses.remove(at: indexPath.row)
            
            tableView.performBatchUpdates({
                tableView.deleteRows(at:[indexPath], with: .automatic)
            }) {_ in
//                Alamofire.request("\(url_api)/unroll?student_id=\(8)&course_id=\(course.id)").response(completionHandler: { (res) in
//
//                })
            }
        default: break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        Alamofire.request("\(url_api)/get_enrolls?student_id=\(studentid!)").response { (res) in
            if let data = res.data {
                let json = JSON(data).arrayValue
//                print(json)
                for index in json {
                    let course = Course(name: index["course_name"].stringValue, id: index["course_id"].intValue)
                    self.courses.append(course)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
