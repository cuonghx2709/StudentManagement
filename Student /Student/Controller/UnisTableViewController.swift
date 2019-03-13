//
//  UnisTableViewController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/25/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class UnisTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    
    var dataTableOriginal : [University] = []
    var dataTableClone: [University] = []
    
    // NOT CALL THIS CASE 
    func updateSearchResults(for searchController: UISearchController) {
        print("Do something")
        let sb = searchController.searchBar
        let target = sb.text!
        if target == "" {
            self.dataTableClone = self.dataTableOriginal
        } else {
            print("cuonghx")
            self.dataTableClone = self.dataTableOriginal.filter { s in
                let options = String.CompareOptions.caseInsensitive
//                if self.seg.selectedSegmentIndex == 1 {
//                    options.insert(.anchored)
//                }
                
                let stringConvert = ConverHelper.convertVietNam(text: target)
                let stringSource = ConverHelper.convertVietNam(text: s.name)
                print(stringConvert)
                print(stringSource)
                if stringSource.smartContains(stringConvert) {
                    return true
                }
                
                let found = s.name.range(of:target, options: options)
                return (found != nil)
            }
        }
        self.tableView.reloadData()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        print("abcd")
        dataTableClone = self.dataTableOriginal
    }
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
            self.dataTableClone = self.dataTableOriginal
        } else {
            self.dataTableClone = self.dataTableOriginal.filter { s in
                let options = String.CompareOptions.caseInsensitive
                //                if self.seg.selectedSegmentIndex == 1 {
                //                    options.insert(.anchored)
                //                }
                let convertString = ConverHelper.convertVietNam(text: target)
                let convertSource = ConverHelper.convertVietNam(text: s.name)
                if convertSource.smartContains(convertString) {
                    return true
                }
                
                let found = convertSource.range(of:convertString, options: options)
                return (found != nil)
            }
        }
        self.tableView.reloadData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.frame = CGRect(x: 0,y: 0,width: self.view.frame.size.width, height: 100.0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//
        let searchBar = UISearchBar.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: UIScreen.main.bounds.width, height: (navigationController?.navigationBar.frame.height)!)))
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
//        let searcher = UISearchController(searchResultsController: nil)
//        searcher.searchResultsUpdater = self
////        self.tableView.tableHeaderView = searcher.searchBar
//        self.navigationItem.searchController = searcher
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//        searcher.hidesNavigationBarDuringPresentation = false
//        searcher.obscuresBackgroundDuringPresentation = false
//
//
//
//        searcher.delegate = self
//        self.navigationItem.titleView = searcher.searchBar
//        self.definesPresentationContext = true
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        getData()
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
        return self.dataTableClone.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let univ = dataTableClone[indexPath.row]
        cell.textLabel?.text = univ.name
        
        return cell
    }

    // MAR: function
    func getData(){
        Alamofire.request("\(url_api)/get_unis").response { (res) in
            if let data = res.data {
                let json = JSON(data).arrayValue
                for univ in json {
                    let university = University(name: univ["uni_name"].stringValue, id: univ["uni_id"].intValue)
                    self.dataTableOriginal.append(university)
                }
                DispatchQueue.main.async {
                    self.dataTableClone = self.dataTableOriginal
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "courses") as! CoursesTableViewController
        let uni = self.dataTableClone[indexPath.row]
        vc.uni = uni
        self.navigationController?.pushViewController(vc, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
