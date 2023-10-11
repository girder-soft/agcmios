//
//  ProjectListModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 27/01/23.
//

import Foundation

struct ProjectListModel {
    let id: Int
    let title: String
    let subTitle: String
    let project: Project
    
    init(project: Project) {
        self.id = project.id
        self.title =  "#" + project.referenceNumber + " - " + project.displayName 
        self.subTitle = project.trade.name
        self.project = project
    }
}

struct Trade: Decodable {
    let id: Int
    let name: String
}


struct Project: Decodable {
    
    let id: Int
    let startDate: String
    let trade: Trade
    let endDate: String
    let displayName: String
    let referenceNumber: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case trade = "trade_id"
        case endDate = "end_date"
        case displayName = "display_name"
        case referenceNumber = "ref_number"
        case latitude = "project_latitude"
        case longitude = "project_longitude"
    }
}


struct User: Decodable {
    let id: Int
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        do {
            email = try container.decode(String.self, forKey: .email)
        } catch DecodingError.typeMismatch {
            email = ""
        }
    }
}
