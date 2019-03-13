//
//  User.swift
//  StudentManagement
//
//  Created by cuonghx on 9/22/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import Foundation

class User: NSCoding  {
    
    var email : String
    var studentID: Int
    var name : String
    var birthday: String
    var vectors : [Array<Int>]
    
    init(email : String, studentID: Int, name : String, birthday : String, vectors : [Array<Int>]) {
        self.email = email
        self.studentID = studentID
        self.name = name
        self.birthday = birthday
        self.vectors = vectors
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.studentID, forKey: "studentID")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.birthday, forKey: "birthday")
        aCoder.encode(self.vectors, forKey: "vectors")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: "email") as! String;
        self.studentID = aDecoder.decodeObject(forKey: "studentID") as! Int
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.birthday = aDecoder.decodeObject(forKey: "birthday") as! String
        self.vectors = aDecoder.decodeObject(forKey: "vectors") as! [Array<Int>]
    }
    
    func prin() {
        print("email: \(self.email)/ studentID: \(self.studentID) / name: \(self.name) /birthday: \(self.birthday) /vectors: \(self.vectors)")
    }
    
}
