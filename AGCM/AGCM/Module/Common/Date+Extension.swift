//
//  Date+Extension.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 07/02/23.
//

import Foundation

extension Date {
    func getOdooDisplayDate(format: String = "YYYY-MM-dd hh:mm:ss aa") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func getOdooServerDate(format: String = "YYYY-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension String {
    func convertFromOdooServerDate(format: String = "YYYY-MM-dd-hh-mm") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self) ?? Date()
    }
}
