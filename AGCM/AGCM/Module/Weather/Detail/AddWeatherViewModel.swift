//
//  AddWeatherViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 29/01/23.
//

import Foundation

class AddWeatherViewModel {
    var viewType: ViewType = .add
    var weather: Weather = Weather()
    var dailyLogId: Int = 0
    private let apiService = WeatherAPI()
    func updateWeatherChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        if viewType == .add {
            apiService.createWeather(weather: weather) { response in
                switch response.result {
                case .success(let result):
                    if result.result != 0 {
                        onSuccess()
                    } else {
                        onError(false)
                    }
                case .failure(let error):
                    onError(error.isSessionTaskError)
                }
            }
        } else if viewType == .edit {
            apiService.updateWeather(weather: weather) { response in
                switch response.result {
                case .success(let result):
                    if result.result {
                        onSuccess()
                    } else {
                        onError(false)
                    }
                case .failure(let error):
                    onError(error.isSessionTaskError)
                }
            }
        }
    }
}
