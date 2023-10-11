//
//  VisitorListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation


struct VisitorListModel {
    var title: String {
        return visitor.name
    }
    var subTitle: String {
        let format = "YYYY-MM-dd hh:mm aa"
        return "Entry Time: \(visitor.entryTime.getOdooDisplayDate(format: format) ) \nExit Time: \(visitor.exitTime.getOdooDisplayDate(format: format))\n\(visitor.reason)"
    }
    let visitor: Visitor
}

struct Visitor: Codable {
    var id: Int = 0
    var dailyLogId: Int = 0
    var name: String = ""
    var reason: String = ""
    var entryTime: Date = Date()
    var exitTime: Date = Date()
    var user: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    var comments: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case dailyLogId = "dailylog_id"
        case name
        case reason
        case entryTime = "visit_entry_time"
        case exitTime = "visit_exit_time"
        case user = "user_id"
        case comments
    }
    
    init(){
        
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dailyLogId = try container.decode(Int.self, forKey: .dailyLogId)
        self.name = try container.decode(String.self, forKey: .name)
        self.reason = try container.decode(String.self, forKey: .reason)
        if let entry = try? container.decode(String.self, forKey: .entryTime) {
            self.entryTime = entry.convertFromOdooServerDate()
        }
        if let exit = try? container.decode(String.self, forKey: .exitTime) {
            self.exitTime = exit.convertFromOdooServerDate()
        }
        self.user = try container.decode(CreateAndSelect.self, forKey: .user)
        self.comments = try container.decode(String.self, forKey: .comments)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dailyLogId, forKey: .dailyLogId)
        try container.encode(comments, forKey: .comments)
        try container.encode(reason, forKey: .reason)
        try container.encode(entryTime.getOdooServerDate() , forKey: .entryTime)
        try container.encode(exitTime.getOdooServerDate(), forKey: .exitTime)
        try container.encode(user.id, forKey: .user)
    }
}
