//
//  PhotosModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import Foundation

struct Photo: Codable {
    let id: Int
    let dailyLogId: Int
    let image: String
    let name: String
    
    enum CodingKeys:String, CodingKey {
        case id
        case dailyLogId = "dailylog_id"
        case image
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dailyLogId = try container.decode(Int.self, forKey: .dailyLogId)
        if let imageString = try? container.decode(String.self, forKey: .image) {
            self.image = imageString
        } else {
            self.image = ""
        }
        self.name = try container.decode(String.self, forKey: .name)
    }
}


struct PhotoDetail: Codable {
    var id: Int = 0
    var dailyLogId: Int = 0
    var image: String = ""
    var name: String = ""
    var fileName: String = ""
    var takenOn: Date = Date()
    var uploadedOn: Date = Date()
    var album: String = ""
    var location: String = ""
    var createdBy: CreateAndSelect = CreateAndSelect(id: 0, name: "")
    
    enum CodingKeys:String, CodingKey {
        case id
        case dailyLogId = "dailylog_id"
        case image
        case name
        case fileName = "file_name"
        case takenOn = "taken_on"
        case uploadedOn = "create_date"
        case album
        case location
        case createdBy = "create_uid"
    }
    
    init() {
        createdBy = CreateAndSelect(id: UserDefaultsManager.shared.userId, name: UserDefaultsManager.shared.getUserName())
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.dailyLogId = try container.decode(Int.self, forKey: .dailyLogId)
        if let imageString = try? container.decode(String.self, forKey: .image) {
            self.image = imageString
        }
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        }
        if let fileName = try? container.decode(String.self, forKey: .fileName) {
            self.fileName = fileName
        }
        if let takenOn = try? container.decode(String.self, forKey: .takenOn) {
            self.takenOn = takenOn.convertFromOdooServerDate()
        }
        if let uploadedOn = try? container.decode(String.self, forKey: .uploadedOn) {
            self.uploadedOn = uploadedOn.convertFromOdooServerDate()
        }
        if let album = try? container.decode(String.self, forKey: .album) {
            self.album = album
        }
        if let location = try? container.decode(String.self, forKey: .location) {
            self.location = location
        }
        if let createdBy = try? container.decode(CreateAndSelect.self, forKey: .createdBy) {
            self.createdBy = createdBy
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.dailyLogId, forKey: .dailyLogId)
        try container.encode(self.image, forKey: .image)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.fileName, forKey: .fileName)
        try container.encode(self.takenOn.getOdooServerDate(), forKey: .takenOn)
        try container.encode(self.album, forKey: .album)
        try container.encode(self.location, forKey: .location)
    }
    
}

