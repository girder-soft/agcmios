//
//  ObservationListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 30/01/23.
//

import Foundation

class ObservationListViewModel {
    var list: [Observation] = []
    var dailyLogId: Int = 0
    let apiService: ObservationAPI = ObservationAPI()
    
    func getObservationList(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getObservationList(dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list = pageResult.result ?? []
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
    func createObservation(observation: Observation, onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.createObservation(observation: observation, onCompletion: { response in
            switch response.result {
            case .success(let response):
                if response.result != 0 {
                    onSuccess()
                } else {
                    onError(false)
                }
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        })
    }
    
}


