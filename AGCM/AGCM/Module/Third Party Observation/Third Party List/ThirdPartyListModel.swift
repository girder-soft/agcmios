//
//  ThirdPartyListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

enum ThirdPartyListType: Int, CaseIterable {
    case safetyObservation = 0, delay = 1, visitor = 2
    
    var title: String {
        switch self {
        case .safetyObservation:
            return "Safety Observations"
        case .delay:
            return "Delay"
        case .visitor:
            return "Visitors"
        }
    }
}

struct ThirdPartyListModel {
    var title: String  {
        return type.title + (count > 0 ? " (\(count))" : "")
    }
    var type: ThirdPartyListType = .safetyObservation
    var count: Int = 0
}

struct ObservationDetail: Decodable {
    let id : Int
    let name: String
    let dailyLogId: Int
    var delays: [Int]
    var safetyObservations: [Int]
    var visitors: [Int] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dailyLogId = "dailylog_id"
        case delays = "delay_lines"
        case safetyObservations = "safety_violation_lines"
    }
}
