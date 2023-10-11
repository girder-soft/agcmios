//
//  SafetyAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation

import Alamofire

struct SafetyAPI {
    private let safetyModel = "/api/safety.violation/"
    
    func getSafetyList(dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Safety>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + safetyModel , method: .get, parameters: ["query": "{id,name,dailylog_id,violation_notice,user_id{id,name},violation_type_id{id,name}, partner_id{id,name}}","filter":filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Safety>.self) { response in
            onCompletion(response)
        }
    }
    
    func createSafety(safety: Safety, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Safety>(params: OdooData(data: safety))
        AF.request(URLConstant.domain + safetyModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }

    func updateSafety(safety: Safety, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Safety>(params: OdooData(data: safety))
        AF.request(URLConstant.domain + safetyModel + String(safety.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}
