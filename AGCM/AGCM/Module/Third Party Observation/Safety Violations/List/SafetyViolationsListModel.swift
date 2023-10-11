//
//  SafetyViolationsListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

struct SafetyViolationsListModel {
    var title: String {
        return safety.name
    }
    var subTitle: String {
        return "Type: \(safety.type.name) \nNotice To: \(safety.partner.name)\n\(safety.comment)"
    }
    let safety: Safety
}

struct Safety: Codable {
    var id: Int = 0
    var name: String = ""
    var dailyLogId: Int = 0
    var comment: String = ""
    var user: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    var type: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    var partner: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dailyLogId = "dailylog_id"
        case comment = "violation_notice"
        case type = "violation_type_id"
        case user = "user_id"
        case partner = "partner_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dailyLogId, forKey: .dailyLogId)
        try container.encode(comment, forKey: .comment)
        try container.encode(type.id, forKey: .type)
        try container.encode(user.id, forKey: .user)
        try container.encode(partner.id, forKey: .partner)
        
    }
}
