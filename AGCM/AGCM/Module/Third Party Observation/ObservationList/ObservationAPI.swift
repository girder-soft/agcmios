//
//  ObservationAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 30/01/23.
//

import Foundation
import Alamofire

struct ObservationAPI {
    private let notesModel = "/api/notes/"
    func getObservationList(dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Observation>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + notesModel , method: .get, parameters: ["query": "{name,id,dailylog_id,description}", "filter": filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Observation>.self) { response in
            onCompletion(response)
        }
    }
    
    func createObservation(observation: Observation, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Observation>(params: OdooData(data: observation))
        AF.request(URLConstant.domain + notesModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func getObservationDetail(id: Int, onCompletion: @escaping(AFDataResponse<ObservationDetail>) -> ()) {
        AF.request(URLConstant.domain + notesModel + String(id) , method: .get, parameters: ["query": "{id,name, dailylog_id,delay_lines,safety_violation_lines}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: ObservationDetail.self) { response in
            onCompletion(response)
        }
    }

    func updateObservation(observation: Observation, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Observation>(params: OdooData(data: observation))
        AF.request(URLConstant.domain + notesModel + String(observation.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}

