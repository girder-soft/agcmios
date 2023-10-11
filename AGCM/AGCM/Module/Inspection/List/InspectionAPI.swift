//
//  InspectionAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation
import Alamofire

struct InspectionAPI {
    private let inspectionModel = "/api/inspection/"
    private let inspectionTypeModel = "/api/inspection.type/"

    func getInspectionList(dailyLogId: Int, onCompletion: @escaping(AFDataResponse<OdooPageResult<Inspection>>) -> ()) {
        let filter = String(format: "[[\"dailylog_id\",\"=\",%d]]", dailyLogId)
        AF.request(URLConstant.domain + inspectionModel , method: .get, parameters: ["query": "{id,dailylog_id,result,inspection_type_id{id,name}}","filter":filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<Inspection>.self) { response in
            onCompletion(response)
        }
    }
    
    func createInspection(inspection: Inspection, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Inspection>(params: OdooData(data: inspection))
        AF.request(URLConstant.domain + inspectionModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }

    func updateInspection(inspection: Inspection, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Inspection>(params: OdooData(data: inspection))
        AF.request(URLConstant.domain + inspectionModel + String(inspection.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}
