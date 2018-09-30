//
//  ModelUniv.swift
//  StudentManagement
//
//  Created by cuonghx on 9/25/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import Foundation

class University {
    var name: String
    var id : Int
    
    init(name : String, id : Int) {
        self.name = name
        self.id = id
    }
}

class Course {
    var name : String
    var id : Int
    
    init(name : String, id : Int) {
        self.name = name
        self.id = id
    }
}
