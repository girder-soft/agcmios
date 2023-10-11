//
//  SafetyViolationDetailViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation

class SafetyViolationDetailViewModel {
    var viewType: ViewType = .add
    var safety: Safety = Safety()
    var dailyLogId: Int = 0
    private let apiService = SafetyAPI()
    func updateSafetyChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        safety.dailyLogId = dailyLogId
        if viewType == .add {
            apiService.createSafety(safety: safety) { response in
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
            apiService.updateSafety(safety: safety) { response in
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
