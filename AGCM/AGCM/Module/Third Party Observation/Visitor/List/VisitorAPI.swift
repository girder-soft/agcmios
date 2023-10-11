//
//  VisitorAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation
import Alamofire

struct VisitorAPI {
    private let visitorModel = "/api/visitor/"
    
    func getVisitors( dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Visitor>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + visitorModel , method: .get, parameters: ["query": "{id,name,reason,visit_entry_time,visit_exit_time,dailylog_id,user_id{id,name},comments}","filter":filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Visitor>.self) { response in
            onCompletion(response)
        }
    }
    
    func createVisitor(visitor: Visitor, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Visitor>(params: OdooData(data: visitor))
        AF.request(URLConstant.domain + visitorModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }

    func updateVisitor(visitor: Visitor, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Visitor>(params: OdooData(data: visitor))
        AF.request(URLConstant.domain + visitorModel + String(visitor.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}
