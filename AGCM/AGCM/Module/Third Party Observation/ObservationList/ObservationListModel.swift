//
//  ObservationListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 30/01/23.
//

import Foundation

struct Observation: Codable {
    var id: Int = 0
    var name: String = ""
    var dailyLogId: Int = 0
    var comments: String = ""
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dailyLogId = "dailylog_id"
        case comments = "description"
    }
    
    init(){}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.dailyLogId = try container.decode(Int.self, forKey: .dailyLogId)
        do {
            self.comments = try container.decode(String.self, forKey: .comments)
        } catch DecodingError.typeMismatch {
            self.comments = ""
        }
    }
}
