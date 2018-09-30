//
//  ViewController.swift
//  TestFireBaseCarthage
//
//  Created by cuonghx on 9/27/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var ref = Database.database().reference(withPath: "YoutubeModel")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let dictiondary = snapshot.value as! NSDictionary
            for dic in dictiondary.allValues {
                let list = (dic as! [String: Any])["list"] as! NSArray
                
                for item in list{
                    let i = item as! [String: Any]
                    print(i["id"])
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

