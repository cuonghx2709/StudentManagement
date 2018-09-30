//
//  HomeController.swift
//  StudentManagement
//
//  Created by cuonghx on 9/30/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    var menuVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController")
        menuVC?.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(responGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(responGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func responGesture(gesture : UISwipeGestureRecognizer){
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right :
            if !AppDelegate.showmenu {
                showMenu()
            }
            break
        case UISwipeGestureRecognizerDirection.left :
            if AppDelegate.showmenu {
                closeMenu()
            }
            break
        default:
            break
        }
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

    @IBAction func menuClicked(_ sender: UIBarButtonItem) {
        print("cuonghx")
        if !AppDelegate.showmenu{
            showMenu()
        }else{
            
            closeMenu()
        }
    }
    func showMenu() {
        if let vc  = self.menuVC {
            AppDelegate.showmenu = !AppDelegate.showmenu
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            UIView.animate(withDuration: 0.3, animations: {
                vc.view.frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                 vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }) { (_) in
               
            }
        }
    }
    func closeMenu(){
        if let vc  = self.menuVC {
           AppDelegate.showmenu = !AppDelegate.showmenu
            UIView.animate(withDuration: 0.3, animations: {
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                vc.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            }) { (_) in
                vc.willMove(toParentViewController: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
           
            
        }
    }
}
