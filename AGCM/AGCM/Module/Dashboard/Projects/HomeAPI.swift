//
//  HomeAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 28/01/23.
//

import Foundation
import Alamofire

class HomeAPI {
    private let userPath = "/api/res.users/"
    private let projectList = "/api/project/"
    func getUser(id: Int, onCompletion: @escaping(AFDataResponse<User>) -> ()) {
        AF.request(URLConstant.domain + userPath + String(id) , method: .get, parameters: ["query": "{id,name,email}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: User.self) { response in
            onCompletion(response)
        }
    }
    
    func getProjectList( onCompletion: @escaping(AFDataResponse<OdooPageResult<Project>>) -> ()) {
        AF.request(URLConstant.domain + projectList  , method: .get, parameters: ["query": "{start_date,trade_id{id,name},end_date,display_name,id,ref_number,project_longitude,project_latitude}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Project>.self) { response in
            onCompletion(response)
        }
    }
    
    
    
}
