//
//  DelayAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation
import Alamofire

struct DelayAPI {
    private let delayModel = "/api/delay/"
    
    func getDelayList( dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Delay>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + delayModel , method: .get, parameters: ["query": "{id,name,delay,reason,reported_by,dailylog_id,partner_id{id,name}}","filter":filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Delay>.self) { response in
            onCompletion(response)
        }
    }
    
    func createDelay(delay: Delay, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Delay>(params: OdooData(data: delay))
        AF.request(URLConstant.domain + delayModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }

    func updateDelay(delay: Delay, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Delay>(params: OdooData(data: delay))
        AF.request(URLConstant.domain + delayModel + String(delay.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}
