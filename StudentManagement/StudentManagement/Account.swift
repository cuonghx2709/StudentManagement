//
//  Account.swift
//  StudentManagement
//
//  Created by cuonghx on 9/22/18.
//  Copyright © 2018 cuonghx. All rights reserved.
//

import Foundation
import Alamofire


class Account: NSObject, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.user, forKey: "user")
        aCoder.encode(self.password, forKey: "password")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.user = aDecoder.decodeObject(forKey: "user") as! String
        self.password = aDecoder.decodeObject(forKey: "password") as! String
    }
    
    var user: String
    var password : String
    
    init(user : String, password : String) {
        self.user = user
        self.password = password
    }
    
}
struct CustomPostEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        let httpBody = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!
        request.httpBody = httpBody.replacingOccurrences(of: "%5B%5D=", with: "=").data(using: .utf8)
        return request
    }
}
