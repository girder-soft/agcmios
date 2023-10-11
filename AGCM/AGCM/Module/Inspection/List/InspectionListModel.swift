//
//  InspectionListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation


struct InspectionListModel {
    var title: String {
       return "Type : " + inspection.type.name
    }
    var subTitle: String {
    inspection.result
    }
    let inspection: Inspection
    init(inspection: Inspection) {
        self.inspection = inspection
    }
}

struct InspectionType: Decodable {
    var id: Int = 0
    var name: String = ""
    
    var createSelectModel: CreateAndSelect {
        return CreateAndSelect(id: id, name: name)
    }
}

struct Inspection: Codable {
    var id: Int = 0
    var dailyLogId: Int = 0
    var result: String = ""
    var type: InspectionType = InspectionType()
    
    enum CodingKeys: String, CodingKey {
        case id
        case dailyLogId = "dailylog_id"
        case result
        case type = "inspection_type_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dailyLogId, forKey: .dailyLogId)
        try container.encode(result, forKey: .result)
        try container.encode(type.id, forKey: .type)

    }
}
