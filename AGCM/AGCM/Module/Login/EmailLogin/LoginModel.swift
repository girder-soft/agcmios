//
//  LoginModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation

struct LoginResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case isAdmin = "is_admin"
    }
    
    let uid: Int
    let name: String
    let isAdmin: Bool
}

struct LoginPostResponse: Encodable {
    struct LoginParam: Encodable {
        let login: String
        let password: String
        let db: String
    }
    let params: LoginParam
}
