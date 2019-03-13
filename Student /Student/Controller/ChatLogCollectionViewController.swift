//
//  ChatLogCollectionViewController.swift
//  TestMessenger
//
//  Created by cuonghx on 11/23/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire

private let reuseIdentifier = "CellChat"

class Messenge : NSObject {
    var text : String?
    var isSender : Bool = false
    var timeStamp : Int = 0
}

class ChatLogCollectionViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    var data = [Messenge]()
    var courseID = 0
    
    let containerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()
    let textField : UITextField =  {
       let tf = UITextField()
        tf.placeholder = "Aa"
//        tf.backgroundColor = UIColor.red
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: tf.frame.height))
        tf.leftViewMode = .always
        tf.layer.cornerRadius = 15
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.gray.cgColor
        return tf
    }()
    let sendButton : UIButton = {
        let btn = UIButton(type: UIButtonType.system)
//        btn.setTitle("Send", for: .normal)
        let image = UIImage(named: "ic_send")!.withRenderingMode(.alwaysOriginal)
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        btn.isUserInteractionEnabled = false
        btn.setTitleColor(UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return btn
    }()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    
    var bottomConstrain:NSLayoutConstraint?
    
    @objc func handleSendButton (){
        let ms = Messenge()
        ms.text = self.textField.text
        ms.isSender = true
        ms.timeStamp = data.count + 1
        
        let para : Parameters = ["message" : ms.text!, "fromId" : Utils.getCurrentUserId()!, "isTeacher" : false]
        Alamofire.request("\(url_api)/message/\(self.courseID)", method: .post, parameters: para).response { (res) in
            if let err = res.error {
                print(err)
            }else {
                print("ok")
            }
        }
        self.textField.text = ""
        hanlerTextFildChange(textField)
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        print("someting")
    }
    
    func setupView(){
        self.collectionView?.addSubview(refreshControl)
        self.view.addSubview(containerView)
        self.view.addConstrainsWithFormat("H:|[v0]|", containerView)
        self.view.addConstrainsWithFormat("V:[v0(48)]", containerView)
        
        bottomConstrain = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstrain!)
        
        containerView.addSubview(textField)
        containerView.addSubview(sendButton)
        
        containerView.addConstrainsWithFormat("H:|-8-[v0][v1(60)]|", textField, sendButton)
        containerView.addConstrainsWithFormat("V:|-8-[v0]-8-|", textField)
        containerView.addConstrainsWithFormat("V:|[v0]|", sendButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if data.count > 0{
            UIView.animate(withDuration: 0.5) {
                self.collectionView?.scrollToItem(at: IndexPath(item: self.data.count - 1, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
            }
        }
       
        self.textField.becomeFirstResponder()
//        self.tabBarController?.tabBar.isHidden = true
        self.textField.addTarget(self, action: #selector(hanlerTextFildChange(_:)), for: .editingChanged)
        observeValueMessage()
    }
    @objc func hanlerTextFildChange(_ textField : UITextField){
        if (textField.text == ""){
            self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.sendButton.isUserInteractionEnabled = false
        }else {
            self.sendButton.setImage(UIImage(named: "ic_sent_chat")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.sendButton.isUserInteractionEnabled = true
        }
    }
    func observeValueMessage(){
//        self.collectionView?.isHidden = true
        self.collectionView?.addActivityIndicatorOverlay({ (remove) in
            let ref = Database.database().reference()
            var check = true
            ref.child("Messenger").child("Course_\(self.courseID)").observe(.childAdded, with: { (snap) in
                remove()
                check = false
//                self.collectionView?.isHidden = false
                if let value = snap.value as? NSDictionary {
                    let mess = Messenge()
                    mess.text = value["text"] as? String
                    mess.isSender = value["isTeacher"] as! Int != 1
                    mess.timeStamp = value["timestamp"] as! Int
                    self.data.append(mess)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.collectionView?.scrollToItem(at: IndexPath(item: self.data.count - 1, section: 0), at: .top, animated: true)
                    }
//                    print(value)
                }
            }) { (err) in
                check = false
                remove()
//                self.collectionView?.isHidden = false
                print(err.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if (check){
                    remove()
                }
            }
        })
    }
    @objc func handleKeyNotification(notification : NSNotification){
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            print(keyboardFrame.height)
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstrain?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded() 
            }) { (cmp) in
                 self.containerView.isHidden = false
                if isKeyboardShowing {
                    if self.data.count > 0{
                        let indexPath = IndexPath(item: self.data.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .top , animated: true)
                    }
                }
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.textField.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getData()
        self.collectionView!.register(ChatLogCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        setupView()
    }
    func getData(){
        let ref = Database.database().reference()
        self.navigationController?.view.addActivityIndicatorOverlay({ (remove) in
            ref.child("Messenger").child("Course_\(self.courseID)").observeSingleEvent(of: .value, with: { (snap) in
                remove()
                if snap.childrenCount > 0{
                    let dataCap = snap.value as! NSDictionary
                    for (index , element) in dataCap {
                        let value = element as! NSDictionary
                        let message = Messenge()
                        message.text = value["text"] as! String
                        message.isSender = value["isTeacher"] as! Int != 1
                        message.timeStamp = value["timestamp"] as! Int
                        self.data.append(message)
                    }
                    self.data = self.data.sorted(by: { $0.timeStamp < $1.timeStamp })
                    DispatchQueue.main.async {
                        if self.data.count > 0{
                            self.collectionView?.reloadData()
                            let indexPath = IndexPath(item: self.data.count - 1, section: 0)
                            self.collectionView?.scrollToItem(at: indexPath, at: .top , animated: true)
                        }
                    }
                    
                }
                
            }) { (err) in
                remove()
                print(err.localizedDescription)
            }
        })
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of item
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatLogCollectionCell
        cell.messengerText.text = data[indexPath.item].text
        cell.profileImageView.image = UIImage(named: "avt")
        cell.profileImageSender.image = UIImage(named: "avt")
        cell.profileImageSender.isHidden = false
        cell.profileImageView.isHidden = false
        
        let message = data[indexPath.row].text
        
        
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        if !data[indexPath.item].isSender{
            let size = CGSize(width: 3*self.view.frame.width/5, height: 1000)
            let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
            cell.messengerText.frame = CGRect(x: 56, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: 40, y: -4, width: estimatedFrame.width + 40, height: estimatedFrame.height + 26)
            cell.profileImageView.isHidden = false
            cell.messengerText.textColor = UIColor.black
            cell.bubbleImageView.image = ChatLogCollectionCell.grayBubble
            cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
            cell.profileImageSender.isHidden = true
            
        }else {
            let size = CGSize(width: 3*self.view.frame.width/5, height: 1000)
            let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
            cell.messengerText.frame = CGRect(x:view.frame.width - estimatedFrame.width - 48 - 4, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 56 - 8, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
            cell.profileImageView.isHidden = true
            cell.messengerText.textColor = UIColor.white
            cell.bubbleImageView.image = ChatLogCollectionCell.bluBubble
            cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        }
    
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = data[indexPath.row].text
        
        let size = CGSize(width: 3*self.view.frame.width/5, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
        return CGSize(width: view.frame.width, height: estimatedFrame.height+20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 56)
    }
}

extension UIView {
    func addConstrainsWithFormat(_ format : String, _ views : UIView...) {
        var viewsDictionary = [String : Any]()
        for (index , view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class ChatLogCollectionCell: BaseCell {
    
    let messengerText : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "This is sample"
        textView.backgroundColor  = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    let textBubbleView : UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    static let grayBubble = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let bluBubble = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    let profileImageView : UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 15
        imageview.layer.masksToBounds = true
        return imageview
    }()
    let bubbleImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogCollectionCell.grayBubble
        imageView.tintColor = UIColor(white: 0.9, alpha: 1)
        return imageView
    }()
    let profileImageSender : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 10
        return image
    }()
    
    override func setupView() {
        addSubview(textBubbleView)
        addSubview(messengerText)
        addSubview(profileImageView)
        addSubview(profileImageSender)
        
        addConstrainsWithFormat("H:|-8-[v0(30)]", profileImageView)
        addConstrainsWithFormat("V:[v0(30)]|", profileImageView)
        profileImageView.backgroundColor = UIColor.red
        
        addConstrainsWithFormat("H:[v0(20)]-8-|", profileImageSender)
        addConstrainsWithFormat("V:[v0(20)]|", profileImageSender)
        profileImageSender.backgroundColor = UIColor.red
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstrainsWithFormat("H:|[v0]|", bubbleImageView)
        textBubbleView.addConstrainsWithFormat("V:|[v0]|", bubbleImageView)
    }
}
class BaseCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupView (){
        
    }
}
