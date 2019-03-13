//
//  Ultils.swift
//  Student
//
//  Created by cuonghx on 12/6/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FirebaseMessaging

class Utils {
    static func getCurrentUserId() -> Int?{
        let preferences = UserDefaults.standard
        let currentKeyID = "studentID"
        if preferences.object(forKey: currentKeyID) == nil {
            return nil
        } else {
            let currentID = preferences.integer(forKey: currentKeyID)
            return currentID
        }
    }
    static func saveCurrentUserID(_ id : Int){
        let preferences = UserDefaults.standard
        let currentID = id
        let currentKeyID = "studentID"
        preferences.set(currentID, forKey: currentKeyID)
        preferences.synchronize()
    }
    
    static func removeCurrentUserID() {
        let preferences = UserDefaults.standard
        let currentKeyID = "studentID"
        let vectorskey = "studentVectors"
        let birthdayKey = "studentBirthday"
        let emailKey = "studentEmail"
        let studentnameKey = "studentName"
        preferences.removeObject(forKey: currentKeyID)
        preferences.removeObject(forKey: vectorskey)
        preferences.removeObject(forKey: birthdayKey)
        preferences.removeObject(forKey: emailKey)
        preferences.removeObject(forKey: studentnameKey)
        preferences.synchronize()
    }
    
    
    static func saveCurrentUser(_ student_id: Int, _ vectors : String , _ birthday : String, _ email : String, student_name: String){
        let idkey = "studentID"
        let vectorskey = "studentVectors"
        let birthdayKey = "studentBirthday"
        let emailKey = "studentEmail"
        let studentnameKey = "studentName"
        let preferences = UserDefaults.standard
        
        preferences.set(student_id, forKey: idkey)
        preferences.set(vectors, forKey: vectorskey)
        preferences.set(birthday, forKey: birthdayKey)
        preferences.set(email, forKey: emailKey)
        preferences.set(student_name, forKey: studentnameKey)
        
        preferences.synchronize()
    }
    static func getCurrentUser() -> UserModel? {
        if getCurrentUserId() == nil {
            return nil
        }else {
            let idkey = "studentID"
            let vectorskey = "studentVectors"
            let birthdayKey = "studentBirthday"
            let emailKey = "studentEmail"
            let studentnameKey = "studentName"
            let preferences = UserDefaults.standard
            
            let user = UserModel(preferences.integer(forKey: idkey), preferences.string(forKey: vectorskey) ?? "", preferences.string(forKey: birthdayKey) ?? "", preferences.string(forKey: emailKey) ?? "", preferences.string(forKey: studentnameKey) ?? "")
            return user
        }
    }
    static func subscriptMessage(){
        Alamofire.request("\(url_api)/enroll/\(getCurrentUserId()!)").response { (res) in
            if let err = res.error {
                print(err)
            }else {
                if let data = res.data {
                    let json = JSON(data)
                    for course in json.arrayValue{
                        Messaging.messaging().subscribe(toTopic: "\(course["course_id"].intValue)") { (err) in
                            print("subcript to \(course["course_id"].intValue) topic")
                        }
                    }
                }
            }
        }
    }
    static func unsubscriptMessage(){
        Alamofire.request("\(url_api)/enroll/\(getCurrentUserId()!)").response { (res) in
            if let err = res.error {
                print(err)
            }else {
                if let data = res.data {
                    let json = JSON(data)
                    for course in json.arrayValue{
                       unsubcriptionMessageCourse(course["course_id"].intValue)
                    }
                }
            }
        }
    }
    static func unsubcriptionMessageCourse(_ course_id : Int){
        Messaging.messaging().unsubscribe(fromTopic: "\(course_id)", completion: { (err) in
            print("unsubcript to \(course_id) topic")
        })
    }
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    static func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        if let _ = dateFormatterGet.date(from: dateString) {
            //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
            return true
        } else {
            // Invalid date
            return false
        }
    }
}

class UserModel {
    var student_id : Int
    var email : String
    var name : String
    var birthday: String
    var vectors : String
    init(_ student_id: Int, _ vectors : String , _ birthday : String, _ email : String, _ student_name: String) {
        self.student_id = student_id
        self.vectors = vectors
        self.birthday = birthday
        self.email = email
        self.name = student_name
    }
}
