//
//  DashboardListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 21/01/23.
//

import Foundation

enum DashboardListType: Int, CaseIterable {
    case weather = 0, manPower = 1, thirdPartyObservation = 2, safety = 3, delay = 4, visitor = 5, inspection = 6, photo = 7
    
    var title: String {
        switch self {
            
        case .weather:
            return "Weather"
        case .manPower:
            return "ManPower"
        case .thirdPartyObservation:
            return "Notes"
        case .safety:
            return "Safety Observation"
        case .delay:
            return "Delay"
        case .visitor:
            return "Visitors"
        case .inspection:
            return "Third Party Inspection"
        case .photo:
            return "Photos"
        }
    }
}

struct DashboardListModel {
    let title: String 
    let type: DashboardListType
    var count: Int = 0
    let subTitle: String
    var displayTitle: String {
        return type.title + (count > 0 ? " (\(count))" : "")
    }
}

struct DailyLogItem: Decodable {
    let id: Int
    let date: String
    let createdBy: CreateAndSelect
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case createdBy = "create_uid"
    }
    
    var createSelect: CreateAndSelect {
        return CreateAndSelect(id:id, name: date + " / By: " + createdBy.name )
    }
}

struct ProjectDailyLogListItem: Decodable {
    
    let id: Int
    let startDate: String
    let trade: Trade
    let endDate: String
    let displayName: String
    let referenceNumber: String
    let dailyLogs: [DailyLogItem]
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case trade = "trade_id"
        case endDate = "end_date"
        case displayName = "display_name"
        case referenceNumber = "ref_number"
        case dailyLogs = "daily_activity_log_lines"
    }
}

struct DailyLogDetail: Decodable {
    struct DailyLogList : Decodable {
        let id: Int
        let totalHours: Double
        let workers: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case totalHours = "total_hours"
            case workers = "number_of_workers"
        }
    }
    
    let id: Int
    let date: String
    var weathers: [Int]
    var manpowers: [DailyLogList]
    var inspections: [Int]
    var photos: [Int]
    var notes: [Int]
    var safety: [Int]
    var delay: [Int]
    var visitor: [Int]

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case weathers = "weather_lines"
        case manpowers = "manpower_lines"
        case inspections = "inspection_lines"
        case photos = "photo_lines"
        case notes = "notes_lines"
        case safety = "safety_violation_lines"
        case delay = "delay_lines"
        case visitor = "visitor_lines"
    }
}

struct CopyDailyLogParam: Encodable {
    let params: CopyDailyLog
}

struct CopyDailyLog: Encodable {
    struct DailyLogContext: Encodable {
        struct DailyLogParam : Encodable {
            let date: String
            let manpower: Bool
            let observation: Bool
            let inspection: Bool
            let delay: Bool
            let safety: Bool
        }
        let context: DailyLogParam
    }
    let kwargs: DailyLogContext
}
