//
//  OdooModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation


struct OdooResponse<T: Decodable>: Decodable {
    struct OdooError: Decodable {
        struct Data: Decodable {
            let name: String
            let message: String
            let debug: String
        }
        let code: Int
        let message: String
        let data: Data
    }
    
    let id: Int?
    let result: T?
    let error: OdooError?
}

struct OdooPageResult<T: Decodable>: Decodable {
    let count: Int?
    let prev: Int?
    let current: Int?
    let next: Int?
    let total_pages: Int?
    let result: [T]?
}

struct OdooData<T: Encodable>: Encodable {
    let data: T
}

struct OdooPostParam<T: Encodable> : Encodable {
    let params: OdooData<T>
}

struct OdooPostResponse: Decodable {
    let result: Int
}

struct OdooPutResponse: Decodable {
    let result: Bool
}

struct URLConstant {
    static let domain = "https://daily.agcm.com"
    static let db = "agcm"
    static let contentType = "Content-type"
    static let applicationJson = "application/json"
}
