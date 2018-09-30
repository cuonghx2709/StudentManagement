//
//  CoursesTableViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/25/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CoursesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate , UISearchBarDelegate{
    
    var dataOriginal = [Course]()
    var result = [Course]()
    var uni: University?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
//        let searcher = UISearchController(searchResultsController: nil)
//        searcher.searchResultsUpdater = self
//        //        self.tableView.tableHeaderView = searcher.searchBar
//        self.navigationItem.searchController = searcher
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//        searcher.hidesNavigationBarDuringPresentation = false
//        searcher.obscuresBackgroundDuringPresentation = false
//        //        self.navigationItem.title = nil
////        self.navigationItem.titleView?.sizeToFit()
        
//        searcher.delegate = self
//        self.navigationItem.titleView = searcher.searchBar
        //        self.definesPresentationContext = true
        
        let searchBar = UISearchBar.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: UIScreen.main.bounds.width, height: (navigationController?.navigationBar.frame.height)!)))
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellCourses")

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return result.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCourses", for: indexPath)
        
        let course = result[indexPath.row]
        cell.textLabel?.text = course.name
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        let target = sb.text!
        if target == "" {
            self.result = self.dataOriginal
        } else {
            self.result = self.dataOriginal.filter { s in
                let options = String.CompareOptions.caseInsensitive
                //                if self.seg.selectedSegmentIndex == 1 {
                //                    options.insert(.anchored)
                //                }
                if s.name.smartContains(target) {
                    return true
                }
                
                let found = s.name.range(of:target, options: options)
                return (found != nil)
            }
        }
        self.tableView.reloadData()
    }
    
    // MAR: function
    func getData(){
        
        Alamofire.request("\(url_api)/get_courses?uni_id=\(self.uni!.id)").response { (res) in
            if let data = res.data {
                let json = JSON(data).arrayValue
                for univ in json {
                    let course = Course(name: univ["course_name"].stringValue, id: univ["course_id"].intValue)
                    self.dataOriginal.append(course)
                    print(course)
                }
                DispatchQueue.main.async {
                    self.result = self.dataOriginal
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Do you want to enroll this courses?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel) { (_) in
            let rootvc = self.navigationController?.viewControllers.first as! HomeViewController
            let course = self.result[indexPath.row]
            print(course.id)
//            print(rootvc.student?.studentID)
            Alamofire.request("\(url_api)/enroll?student_id=\(rootvc.student!.studentID)&course_id=\(course.id)").response(completionHandler: { (res) in
                print("sucess")
            })
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: {
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
    }
    // MARK: searchbar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 1000) {
            searchBar.showsCancelButton = true
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 1000) {
            searchBar.showsCancelButton = false
        }
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let target = searchText
        if target == "" {
            self.result = self.dataOriginal
        } else {
            self.result = self.dataOriginal.filter { s in
                let options = String.CompareOptions.caseInsensitive
                //                if self.seg.selectedSegmentIndex == 1 {
                //                    options.insert(.anchored)
                //                }
                if s.name.smartContains(target) {
                    return true
                }
                
                let found = s.name.range(of:target, options: options)
                return (found != nil)
            }
        }
        self.tableView.reloadData()
    }

}
