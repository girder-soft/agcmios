//
//  WeatherViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

class WeatherViewModel {
    var list: [WeatherModel] = []
    var dailyLogId: Int!
    var project: Project!
    private let apiService: WeatherAPI = WeatherAPI()
        
    func getWeathers(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        
        apiService.getWeatherList(id: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let weatherList):
                self?.list =  weatherList.list.map{WeatherModel(weather: $0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
}
