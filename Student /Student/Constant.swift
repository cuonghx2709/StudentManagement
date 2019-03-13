//
//  Constant.swift
//  StudentManagement
//
//  Created by cuonghx on 9/22/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import Foundation
//let url_api = "http://192.168.100.6:5050"
//let url_api = "http://192.168.1.21:5050"
let url_api = "http://128.199.145.205:5050"
let nameCloud = "cuonghx"
let apiKeyCloud = "228513834739321"

extension String {
    func smartContains(_ other: String) -> Bool {
        let array : [String] = other.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
        return array.reduce(true) { !$0 ? false : (self.lowercased().range(of: $1) != nil ) }
    }
}
