//
//  ManPowerListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 22/01/23.
//

import Foundation


struct ManPowerListModel {
    var title: String {
        manPower.contractor.name
    }
    
    var subTitle: String {
        return String(format: "%d workers * %0.2f hours = %0.2f total hours \nLocation: %@", manPower.workers, manPower.hours, manPower.totalHours, manPower.location)
    }
    
    let manPower: ManPower
    init(manPower: ManPower) {
        self.manPower = manPower
    }
}

struct Contractor: Decodable, Equatable {
    var description: String {
        name
    }
    var id: Int = 0
    var name: String = ""
    
    var createSelectModel: CreateAndSelect {
        return CreateAndSelect(id: id, name: name)
    }
}

struct ManPower: Codable {
    var id: Int = 0
    var comments: String = ""
    var location: String = ""
    var workers: Int = 0
    var hours: Double = 0.0
    var totalHours: Double = 0.0
    var contractor: Contractor = Contractor()
    var dailyLogId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case comments = "name"
        case location
        case workers = "number_of_workers"
        case hours = "number_of_hours"
        case totalHours = "total_hours"
        case contractor = "partner_id"
        case dailyLogId = "dailylog_id"
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(comments, forKey: .comments)
        try container.encode(location, forKey: .location)
        try container.encode(workers, forKey: .workers)
        try container.encode(hours, forKey: .hours)
        try container.encode((Double(workers) * hours), forKey: .totalHours)
        try container.encode(contractor.id, forKey: .contractor)
        try container.encode(dailyLogId, forKey: .dailyLogId)
    }
    
    init() {
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dailyLogId = try container.decode(Int.self, forKey: .dailyLogId)
        if let comment = try? container.decode(String.self, forKey: .comments) {
            self.comments = comment
        }
        if let location = try? container.decode(String.self, forKey: .location) {
            self.location = location
        }
        self.workers = try container.decode(Int.self, forKey: .workers)
        self.hours = try container.decode(Double.self, forKey: .hours)
        self.totalHours = try container.decode(Double.self, forKey: .totalHours)
        self.contractor = try container.decode(Contractor.self, forKey: .contractor)
    }
}

struct ManPowerList: Decodable {
    let list: [ManPower]
    enum CodingKeys: String, CodingKey {
        case list = "manpower_lines"
    }
}
