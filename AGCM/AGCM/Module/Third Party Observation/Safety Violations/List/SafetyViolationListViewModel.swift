//
//  SafetyViolationListViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 24/01/23.
//

import Foundation

class SafetyViolationListViewModel {
    var list: [SafetyViolationsListModel] = []
    var dailyLogId: Int = 0
    private let apiService = SafetyAPI()
    
    func getSafetyList(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        apiService.getSafetyList(dailyLogId: dailyLogId) {[weak self] response in
            switch response.result {
            case .success(let pageResult):
                self?.list =  (pageResult.result ?? []).map{SafetyViolationsListModel(safety: $0)}
                onSuccess()
            case .failure(let error):
                onError(error.isSessionTaskError)
            }
        }
    }
    
}
