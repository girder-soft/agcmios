//
//  DelayListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation


struct DelayListModel {
    var title: String {
        return delay.name 
    }
    var subTitle: String {
        return "Reported By:\(delay.reportedBy) \n\(delay.reason)"
    }
    let delay: Delay
}

struct Delay: Codable {
    var id: Int = 0
    var name: String = ""
    var delay: String = ""
    var reason: String = ""
    var reportedBy: String = ""
    var dailyLogId: Int = 0
    var partner: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case delay
        case reason
        case reportedBy = "reported_by"
        case dailyLogId = "dailylog_id"
        case partner = "partner_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(delay, forKey: .delay)
        try container.encode(reason, forKey: .reason)
        try container.encode(reportedBy, forKey: .reportedBy)
        try container.encode(dailyLogId, forKey: .dailyLogId)
        try container.encode(partner.id, forKey: .partner)
    }
}
