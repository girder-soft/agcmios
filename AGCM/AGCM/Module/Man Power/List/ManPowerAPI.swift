//
//  ManPowerAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation
import Alamofire

struct ManPowerAPI {
    private let dailyLogsModel = "/api/daily.activity.log/"
    private let manPowerModel = "/api/man.power/"
    func getManPowerList(id: Int, onCompletion: @escaping(AFDataResponse<ManPowerList>) -> ()) {
        AF.request(URLConstant.domain + dailyLogsModel + String(id) , method: .get, parameters: ["query": "{manpower_lines{id,name,dailylog_id,location,number_of_workers,number_of_hours,total_hours,partner_id{id,name}}}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: ManPowerList.self) { response in
            onCompletion(response)
        }
    }
    
    func createManPower(manPower: ManPower, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<ManPower>(params: OdooData(data: manPower))
        AF.request(URLConstant.domain + manPowerModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func updateManPower(manPower: ManPower, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<ManPower>(params: OdooData(data: manPower))
        AF.request(URLConstant.domain + manPowerModel + String(manPower.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
}
