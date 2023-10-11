//
//  WeatherModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

protocol DataUpdateProtocol: AnyObject {
    func didDataUpdated()
}

enum WeatherType {
    case dailySnapShot, dailyReport
}

struct WeatherSectionModel {
    let title: String
    let type: WeatherType 
    let rows: [WeatherModel]
}

struct WeatherModel {
    var title: String {
        return String(format: "Temperature : %0.2f %@",weather.temperature, weather.temperatureType )
    }
    var subTitle: String {
        return String(format: "Weather : %@ \nRain : %0.2f", weather.climate.capitalized, weather.rainFall )
    }
    let weather: Weather
}


struct WeatherList: Decodable {
    let list: [Weather]
    enum CodingKeys: String, CodingKey {
        case list = "weather_lines"
    }
}

struct Weather: Codable {

    var id: Int = 0
    var dailyLogId: Int = 0
    var rain: Bool = false
    var rainFall : Double = 0.0
    var climate: String = "clear"
    var temperatureType: String = "F"
    var temperature: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case id
        case dailyLogId = "dailylog_id"
        case rain
        case rainFall = "rain_fall"
        case climate = "climate_type"
        case temperatureType = "temperature_type"
        case temperature
    }
}
