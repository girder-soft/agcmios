//
//  ProjectAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 28/01/23.
//

import Foundation
import Alamofire

struct ProjectAPI {
    private let projectList = "/api/project/"
    private let dailyLogModel = "/api/daily.activity.log/"
    private let copyDailyLogURL = "/object/copy_daily_log/"
    private let reportURL = "/dailylog/%d/print"
    func getDailyLogDetail(id: Int, onCompletion: @escaping(AFDataResponse<DailyLogDetail>) -> ()) {
        AF.request(URLConstant.domain + dailyLogModel + String(id) , method: .get, parameters: ["query": "{id,date,weather_lines,manpower_lines{id,total_hours,number_of_workers},photo_lines,inspection_lines,notes_lines,visitor_lines,delay_lines,safety_violation_lines}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: DailyLogDetail.self) { response in
            onCompletion(response)
        }
    }
    
    func getDailyLogList(id: Int, onCompletion: @escaping(AFDataResponse<ProjectDailyLogListItem>) -> ()) {
        AF.request(URLConstant.domain + projectList + String(id) , method: .get, parameters: ["query": "{display_name,id,trade_id{id,name},end_date,start_date,ref_number,daily_activity_log_lines{id,date,create_uid{id,name}}}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: ProjectDailyLogListItem.self) { response in
            onCompletion(response)
        }
    }
    
    func createDailyLog(dailyLog: DailyLogCreate , onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<DailyLogCreate>(params: OdooData(data: dailyLog))
        AF.request(URLConstant.domain + dailyLogModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func copyDailyLog(dailyLogId: Int, copyDailyLog: CopyDailyLog , onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = CopyDailyLogParam(params: copyDailyLog)
        AF.request(URLConstant.domain + copyDailyLogURL + String(dailyLogId)  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func report(dailyLogId: Int, onCompletion: @escaping(AFDataResponse<Data>) -> ()) {
        AF.request(URLConstant.domain + String(format: reportURL, dailyLogId) , method: .get).responseData(completionHandler: { response in
            onCompletion(response)
        })
    }
}

