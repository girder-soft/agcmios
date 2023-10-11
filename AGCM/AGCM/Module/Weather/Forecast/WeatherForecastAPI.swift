//
//  WeatherForecastAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 13/02/23.
//

import Foundation
import Alamofire

struct WeatherForecastAPI {
    func getWeatherForecast(lat: Double, long: Double, date: String, onCompletion: @escaping(AFDataResponse<WeatherForecastDetail>) -> ()) {
        let forecastURL = String(format: "https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&hourly=temperature_2m,relativehumidity_2m,precipitation,weathercode,windspeed_10m,windgusts_10m&temperature_unit=fahrenheit&windspeed_unit=mph&precipitation_unit=inch&timezone=America/New_York&start_date=%@&end_date=%@",lat,long,date,date)
        AF.request(forecastURL).responseDecodable(of: WeatherForecastDetail.self) { response in
            onCompletion(response)
        }
    }
}

struct WeatherForecastDetail: Decodable {
    struct Hourly: Decodable {
        let precipitation: [CGFloat]
        let humidity: [Int]
        let temperature: [CGFloat]
        let time: [String]
        let weatherCode: [Int]
        let gusts: [CGFloat]
        let wind: [CGFloat]
        
        enum CodingKeys: String, CodingKey {
            case precipitation = "precipitation"
            case humidity = "relativehumidity_2m"
            case temperature = "temperature_2m"
            case time
            case weatherCode = "weathercode"
            case gusts = "windgusts_10m"
            case wind = "windspeed_10m"
        }
    }
    let hourly: Hourly
}

struct WeatherForecast: Codable {
    let precipitation: CGFloat
    let humidity: Int
    let temperature: CGFloat
    let time: String
    let weatherCode: Int
    let wind: CGFloat
    let projectId: Int
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case precipitation
        case humidity
        case temperature
        case time = "time_interval"
        case weatherCode = "weather_code"
        case wind
        case projectId = "project_id"
        case date
    }
}


struct WeatherForecastViewModel {
    let weatherDetail: WeatherForecastDetail
    let projectId: Int
    let date: String
    
    func getWeatherForecastList() -> [WeatherForecast] {
        var foreCastList: [WeatherForecast] = []
        for i in 2 ... 7{
            let hourly = weatherDetail.hourly
            let index = i * 3
            let forecast = WeatherForecast(precipitation: hourly.precipitation[index], humidity: hourly.humidity[index], temperature: hourly.temperature[index], time: hourly.time[index], weatherCode: hourly.weatherCode[index], wind: hourly.wind[index], projectId: projectId, date: date)
            foreCastList.append(forecast)
        }
        return foreCastList
    }
}


class WeatherForecastUpdater {
    var projectId: Int = 0
    var date: String = ""
    var lat: Double = 0
    var long: Double = 0
    
    private let weatherAPI = WeatherAPI()
    private let weatherForecastAPI = WeatherForecastAPI()
    
    func updateWeatherForecast(projectId: Int, date: String, lat: Double, long: Double, onCompletion: @escaping(Bool)->()) {
        self.projectId = projectId
        self.date = date
        self.lat = lat
        self.long = long
        checkWeatherForecastIsAvailable {[weak self] updateForecast in
            if updateForecast {
                self?.createWeatherForecast(onCompletion: onCompletion)
            } else {
                onCompletion(false)
            }
        }
    }
    
    private func checkWeatherForecastIsAvailable(onCompletion: @escaping(Bool) -> ()) {
        weatherAPI.getWeatherForecastList(projectId: projectId, date: date) { response in
            switch response.result {
            case .success(let pageResult):
                onCompletion(pageResult.result?.count == 0)
            case .failure(_):
                onCompletion(false)
            }
        }
    }
    
    private func createWeatherForecast(onCompletion: @escaping(Bool)->()) {
        weatherForecastAPI.getWeatherForecast(lat: self.lat, long: self.long, date: self.date) {[weak self] response in
            switch response.result {
            case .success(let detail):
                self?.createWeatherForcastList(weatherDetail: detail, onCompletion: onCompletion)
            case .failure(_):
                onCompletion(false)
            }
        }
    }
    
    private func createWeatherForcastList(weatherDetail: WeatherForecastDetail, onCompletion: @escaping(Bool)->()) {
        let weatherModel = WeatherForecastViewModel(weatherDetail: weatherDetail, projectId: projectId, date: date)
        let forecastList = weatherModel.getWeatherForecastList()
        let group = DispatchGroup()
        for forecast in forecastList {
            group.enter()
            weatherAPI.createWeatherForecast(forecast: forecast) { response in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            onCompletion(true)
        }
    }
    
    
}
