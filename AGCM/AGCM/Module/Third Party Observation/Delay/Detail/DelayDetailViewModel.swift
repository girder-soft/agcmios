//
//  DelayDetailViewModel.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 31/01/23.
//

import Foundation

class DelayDetailViewModel {
    var viewType: ViewType = .add
    var delay: Delay = Delay()
    var dailyLogId: Int = 0
    private let apiService = DelayAPI()
    func updateDelayChanges(onSuccess: @escaping() -> (), onError: @escaping(Bool) -> ()) {
        delay.dailyLogId = dailyLogId
        if viewType == .add {
            apiService.createDelay(delay: delay) { response in
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
            apiService.updateDelay(delay: delay) { response in
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
