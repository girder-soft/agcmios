//
//  WeatherAPI.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation

import Alamofire

struct WeatherAPI {
    private let dailyLogsModel = "/api/daily.activity.log/"
    private let weatherModel = "/api/weather/"
    private let weatherForecastModel = "/api/weather.forecast/"


    func getWeatherList(id: Int, onCompletion: @escaping(AFDataResponse<WeatherList>) -> ()) {
        AF.request(URLConstant.domain + dailyLogsModel + String(id) , method: .get, parameters: ["query": "{weather_lines{id,dailylog_id,rain,rain_fall,climate_type,temperature_type,temperature}}"], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: WeatherList.self) { response in
            onCompletion(response)
        }
    }
    
    func createWeather(weather: Weather, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<Weather>(params: OdooData(data: weather))
        AF.request(URLConstant.domain + weatherModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func updateWeather(weather: Weather, onCompletion: @escaping(AFDataResponse<OdooPutResponse>) -> ()) {
        let postData = OdooPostParam<Weather>(params: OdooData(data: weather))
        AF.request(URLConstant.domain + weatherModel + String(weather.id)  , method: .put, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPutResponse.self) { response in
            onCompletion(response)
        }
    }
    
    func getWeatherForecastList(projectId: Int, date: String, onCompletion: @escaping(AFDataResponse<OdooPageResult<WeatherForecast>>) -> ()) {
        let filter = String(format: "[[\"project_id\",\"=\",%d],[\"date\",\"=\",\"%@\"]]", projectId,date)
        AF.request(URLConstant.domain + weatherForecastModel  , method: .get, parameters: ["query": "{id,date,project_id,time_interval,temperature,weather_code,humidity,wind,precipitation}", "filter":filter], encoder: URLEncodedFormParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPageResult<WeatherForecast>.self) { response in
            onCompletion(response)
        }
    }
    
    func createWeatherForecast(forecast: WeatherForecast, onCompletion: @escaping(AFDataResponse<OdooPostResponse>) -> ()) {
        let postData = OdooPostParam<WeatherForecast>(params: OdooData(data: forecast))
        AF.request(URLConstant.domain + weatherForecastModel  , method: .post, parameters: postData, encoder: JSONParameterEncoder.default, headers: [URLConstant.contentType :URLConstant.applicationJson]).responseDecodable(of: OdooPostResponse.self) { response in
            onCompletion(response)
        }
    }
}
